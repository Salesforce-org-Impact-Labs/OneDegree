import { LightningElement, track } from 'lwc';
import upsertAPIKeysOnSave from '@salesforce/apex/UpsertAPIKeys.upsertAPIKeysOnSave'

export default class ManageOneDegreeAPIKeys extends LightningElement {

    googleAPIKey
    odAPIKey
    @track apexMessage = ''


    handleGoogleAPIKeyChange(event) {
        try{
            this.googleAPIKey = event.detail.value
        }catch(err) {
            this.apexMessage = this.apexMessage + err
        }
    }

    handleODAPIKeyChange(event) {
        try{
            this.odAPIKey = event.detail.value
        }catch(err) {
            this.apexMessage = this.apexMessage + err
        }
    }
    handleSave() {
        try{
            upsertAPIKeysOnSave({googleAPIKey: this.googleAPIKey, oneDegreeAPIKey: this.odAPIKey})
                .then((result) => {
                    if(result) {
                        this.apexMessage = this.apexMessage + result
                    }
                })
                .catch((error) => {
                    if(error){
                        this.apexMessage = this.apexMessage + error
                    }
                })
        }catch(err) {
            if(err) {
                this.apexMessage = this.apexMessage + err
            }            
        }

    }
}