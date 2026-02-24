import { LightningElement, wire } from 'lwc';
import getTarifications from '@salesforce/apex/TransporterSelector.getTarifications';

export default class TransporterList extends LightningElement {

    tarifs;

    @wire(getTarifications)
    wiredTarifs({ data, error }) {
        if (data) {
            this.tarifs = data;
        } else if (error) {
            console.error(error);
        }
    }
}