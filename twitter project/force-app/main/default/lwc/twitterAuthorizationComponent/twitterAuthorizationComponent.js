import { LightningElement, wire } from 'lwc';
import getTwitterUserSettings from '@salesforce/apex/TwitterAuthController.getTwitterUserSettings';

const SPLITSYMBOL = '~';

export default class TwitterAuthorizationComponent extends LightningElement {
    twitterUserSetting;
    username;
    expirationDateTime;

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

    handleAuthorization() {
        const clientId = 'T3N2bG5JcnB2S09JWHI4YlVHSWE6MTpjaQ';
        const redirectUri = 'https://resilient-wolf-fqzlz-dev-ed--c.vf.force.com/apex/intermidiateIntegrationVFPage';
        const responseType = 'code';
        const scope = 'tweet.read tweet.write users.read offline.access';
        const state = 'state';
        const challenge = 'challenge';
        const plain = 'plain';
        
        const authorizationUrl = `https://twitter.com/i/oauth2/authorize?response_type=${responseType}&client_id=${clientId}&redirect_uri=${encodeURIComponent(redirectUri)}&scope=${encodeURIComponent(scope)}&state=${state}&code_challenge=${challenge}&code_challenge_method=${plain}`;
        console.log();
        window.location.href = authorizationUrl;
    }

    @wire(getTwitterUserSettings)
    getTwitterUserSettings(result) {
        this.twitterUserSetting = result;
        if(result.data) {
            console.log('result.data ' + result.data);
            [ this.username, this.expirationDateTime ] = result.data.split(SPLITSYMBOL);
        }
    }
}