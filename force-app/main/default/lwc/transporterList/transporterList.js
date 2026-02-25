import { LightningElement, wire } from 'lwc';
import getTarifications from '@salesforce/apex/TransporterSelector.getTarifications';

export default class TransporterList extends LightningElement {
    tarifs = [];

    @wire(getTarifications)
    wiredTarifs({ data, error }) {
        if (data && Array.isArray(data)) {

            const cheapestId = data[0]?.Id;
            const fastestId = data[1]?.Id;

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
