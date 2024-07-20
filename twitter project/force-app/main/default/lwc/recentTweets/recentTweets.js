import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, MessageContext } from 'lightning/messageService';
import { RefreshEvent } from 'lightning/refresh';
import TWEET_CREATION_MESSAGE from '@salesforce/messageChannel/TweetCreationMessageChannel__c';
import getTweetsByContactID from '@salesforce/apex/TweetController.getTweetsByContactID';
import deleteTweet from '@salesforce/apex/TweetController.deleteTweet';
import isUserAndUsernameSame from '@salesforce/apex/TweetController.isUserAndUsernameSame';

const actions = [
    { label: 'Delete', name: 'delete' }
];

const columns = [
    { label: '№', fieldName: 'positionNumber', type: 'number', initialWidth: 75 },
    { label: 'Tweet Text', fieldName: 'Tweet_Text__c' },
    { label: 'Tweet Date', fieldName: 'Tweet_Date__c', 
        type: 'date', 
        typeAttributes:{
            year: "numeric",
            month: "long",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        }  
    },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];

const DEFAULT_PAGE_COUNT = 1;
const DEFAULT_PAGE_SIZE = 5;

export default class RecentTweets extends LightningElement {
    @api
    recordId;

    @track
    tweetChunks = [];
    tweetLength;
    
    columns = columns;
    pageIndex = 1;
    wiredTweetsResult;

    get pageCount() {
        return Math.ceil(this.tweetLength/DEFAULT_PAGE_SIZE) ?? DEFAULT_PAGE_COUNT;
    }

    get isPrevious() {
        return this.pageIndex == DEFAULT_PAGE_COUNT;
    }

    get isNext() {
        return this.pageIndex == Math.ceil(this.tweetLength/DEFAULT_PAGE_SIZE);
    }

    get pageDataByPageIndex() {
        return this.tweetChunks[this.pageIndex-1];
    }

    @wire(MessageContext)
    messageContext;

    @wire(getTweetsByContactID, { contactId: '$recordId' }) // maybe better to use async loading but for demo the amount of records is small
    getContacts(result) {
        this.wiredTweetsResult = result;
        const { data, error } = result;
        if (data) {
            this.tweetLength = data.length;
            let tweetData = data.map((item, index) => {
                return { ...item, positionNumber: index + 1 };
            });

            this.tranformDataIntoChunks(tweetData);
        }
    }

    tranformDataIntoChunks(data) {
        let index = 0;
        let chunks = [];

        while (index < this.tweetLength) {
            chunks.push(data.slice(index, index += DEFAULT_PAGE_SIZE));
        }

        this.tweetChunks = chunks;
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }
    
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;  
        }
    }

    async deleteRow(tweet) {
        let isUsernamesEqual =  await isUserAndUsernameSame({ contactId : this.recordId});

        if (!isUsernamesEqual && isUsernamesEqual != undefined) {
            this.showToast('Error','The Username on contact and your do not match. Please, do tweets on your records', 'error'); // maybe normal validation shoudl be here
            return;
        }

        deleteTweet({ tweetId: tweet.Name})
            .then(res => {
                console.log(res);
                if(res) {
                    this.showToast('Success','Tweet was deleted', 'success');
                    refreshApex(this.wiredTweetsResult);
                } else {
                    this.showToast('Error', 'Please try again', 'error');
                }
            })
            .catch(error => {
                
            });
    }

    handlePageChange(event) {
        const dataSetId = event.target.dataset.id;
        switch (dataSetId) {
            case 'next':
                this.pageIndex++;
                break;
            case 'prev':
                this.pageIndex--;
                break;
        }
    }

    subscribeToMessageChannel() {
        subscribe(this.messageContext, TWEET_CREATION_MESSAGE, (message) => {
            this.handleMessage(message);
        });
    }

    handleMessage(message) {
        if (message) {
            refreshApex(this.wiredTweetsResult);
            this.refreshStandartComponents();
        }
    }

    refreshStandartComponents() {
        this.dispatchEvent(new RefreshEvent());
    }

    showToast(title, msg, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: msg,
                variant: variant,
                mode: 'sticky'
            }),
        );
    }
}