import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTransporters from '@salesforce/apex/TransporterOrchestrator.getAllTransporters';
import createLivraison from '@salesforce/apex/OrderService.createLivraison';


export default class TransporterList extends LightningElement {
    @api recordId;
    @api pays;
    @api typeClient;
    selectedTarificationId;


    tarifs = [];
    
    get transporterLabel() {
    const paysLabel = this.pays ?? '';
    const typeClientLabel = this.typeClient ?? '';

    if (paysLabel && typeClientLabel) {
        return `Sélectionnez un Transporteur (${paysLabel} : Client ${typeClientLabel} )`;
    }

    if (paysLabel) {
        return `Sélectionnez un Transporteur (${paysLabel})`;
    }

    if (typeClientLabel) {
        return `Sélectionnez un Transporteur (Client ${typeClientLabel} )`;
    }

    return 'Sélectionnez un Transporteur';
    }

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

    

    get isCreateDisabled() {
        return !this.selectedTarificationId;
        }

    handleSelection(event) {
        this.selectedTarificationId = event.target.value;
        }
        
    handleCreateLivraison() {
        createLivraison({ orderId: this.recordId, selectedTarificationId: this.selectedTarificationId })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Succès',
                        message: 'Livraison créée avec succès!',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erreur',
                        message: 'Erreur lors de la création de la livraison: ' + (error.body?.message || error.message),
                        variant: 'error'
                    })
                );
            });
        }

  
}
