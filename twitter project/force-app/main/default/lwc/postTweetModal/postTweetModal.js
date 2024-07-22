import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import TWEET_CREATION_MESSAGE from '@salesforce/messageChannel/TweetCreationMessageChannel__c';
import createTweet from '@salesforce/apex/TweetController.createTweet';
import isUserAndUsernameSame from '@salesforce/apex/TweetController.isUserAndUsernameSame';
import createTweetRecord from '@salesforce/apex/TweetController.createTweetRecord';

export default class PostTweetModal extends LightningElement {
    @api
    recordId;

    @wire(MessageContext)
    messageContext;

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    async handlePost() {
        let tweetTextField = this.template.querySelector('lightning-textarea');
        let tweetText = tweetTextField.value;
        if (!tweetText) {
            this.showToast('Error','Please provide any text in Tweet Text field', 'error'); // maybe normal validation shoudl be here
            return;
        }

        let isUsernamesEqual =  await isUserAndUsernameSame({ contactId : this.recordId});

        if (!isUsernamesEqual && isUsernamesEqual != undefined) {
            this.showToast('Error','The Username on contact and your do not match. Please, do tweets on your records', 'error'); // maybe normal validation shoudl be here
            return;
        }

        try {
            let tweetId = await createTweet({ tweetText: tweetText });
            let isTweetInserted;

            if (tweetId && tweetId != undefined) {
                isTweetInserted = await createTweetRecord({ tweetText: tweetText, tweetId: tweetId, contactId: this.recordId});
            }

            if (isTweetInserted && isTweetInserted != undefined) {
                const message = { isTweetUpdated: true };
                publish(this.messageContext, TWEET_CREATION_MESSAGE, message);
            } else {
                this.closeModal();
                this.showToast('Error','Something happaned', 'error');
                return;
            }
        } catch (error) {
            console.log('error ' + error + '  ' + JSON.stringify(error));
        }

        this.closeModal();
        this.showToast('Success','Tweet created!', 'success');
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