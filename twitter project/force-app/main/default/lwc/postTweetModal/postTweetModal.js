import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PostTweetModal extends LightningElement {
    @api
    recordId;


    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handlePost() {
        let tweetTextField = this.template.querySelector('lightning-textarea');
        let tweetText = tweetTextField.value;
        console.log('******** ' + tweetText);
        if (!tweetText) {
            this.showToast('Error','Please provide any text in Tweet Text field', 'error'); // maybe normal validation shoudl be here
            return;
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
            }),
        );
    }
}