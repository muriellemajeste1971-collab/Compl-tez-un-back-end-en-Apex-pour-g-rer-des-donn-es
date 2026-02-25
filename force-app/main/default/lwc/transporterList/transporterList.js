import { LightningElement, api, wire } from 'lwc';
import getTransporters from '@salesforce/apex/TransporterOrchestrator.getAllTransporters';


export default class TransporterList extends LightningElement {
    @api recordId;
    tarifs = [];

    @wire(getTransporters, { orderId: '$recordId' }) 
    wiredTarifs({ data, error }) {
        if (data && Array.isArray(data)) {

            
            const fastestId = data[0]?.Id;
            const cheapestId = data[1]?.Id;

            this.tarifs = data.map(t => ({
                ...t,
                isCheapest: t.Id === cheapestId,
                isFastest: t.Id === fastestId
            }));

        } else if (error) {
            console.error(error);
        }
    }

    handleSelection(event) {
        this.selectedTransporterId = event.target.value;
    }
}
