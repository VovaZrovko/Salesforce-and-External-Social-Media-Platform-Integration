import { LightningElement, wire } from 'lwc';
import getTwitterUserSettings from '@salesforce/apex/TwitterAuthController.getTwitterUserSettings';
import getTwitterAppConfig from '@salesforce/apex/TwitterAuthController.getTwitterAppConfig';

const DELIMITER = '~';
const AUTHORIZEURL = 'https://twitter.com/i/oauth2/authorize?';

export default class TwitterAuthorizationComponent extends LightningElement {
    twitterUserSetting;
    username;
    expirationDateTime;
    redirectUri;
    clientId;

    get cardTitle() {
        return 'You are authorized as ' + this.username;
    }

    get ifSessionExpired() {
        if (this.expirationDateTime) {
            return new Date(this.expirationDateTime) > new Date();
        }
    }

    get formattedExpirationDateTime() {
        return new Date(this.expirationDateTime).toLocaleString();
    }

    async connectedCallback() {
        let config = await getTwitterAppConfig();
        [ this.redirectUri, this.clientId ] = config.split(DELIMITER);
    }

    handleAuthorization() {
        const responseType = 'code';
        const scope = 'tweet.read tweet.write users.read offline.access';
        const state = 'state';
        const challenge = 'challenge';
        const plain = 'plain';
        const authorizationUrl = AUTHORIZEURL + `response_type=${responseType}&client_id=${this.clientId}&redirect_uri=${encodeURIComponent(this.redirectUri)}&scope=${encodeURIComponent(scope)}&state=${state}&code_challenge=${challenge}&code_challenge_method=${plain}`;

        window.location.href = authorizationUrl;
    }

    @wire(getTwitterUserSettings)
    getTwitterUserSettings(result) {
        this.twitterUserSetting = result;

        if(result.data) {
            [ this.username, this.expirationDateTime ] = result.data.split(DELIMITER);
        }
    }
}