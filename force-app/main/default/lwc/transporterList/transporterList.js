import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTransporters from '@salesforce/apex/TransporterOrchestrator.getAllTransporters';
import createLivraison from '@salesforce/apex/OrderService.createLivraison';
import { getRecord } from 'lightning/uiRecordApi';
import PAYS_FIELD from '@salesforce/schema/Order.Pays__c';
import TYPE_FIELD from '@salesforce/schema/Order.Account_Type__c';



export default class TransporterList extends LightningElement {
    @api recordId;
    selectedTarificationId;


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

    @wire(getRecord, { recordId: '$recordId', fields: [PAYS_FIELD, TYPE_FIELD] })
        order;

    get pays() {
        return this.order.data?.fields.Pays__c.value;
        }

    get typeClient() {
        return this.order.data?.fields.Account_Type__c.value;
        }
    
    get transporterLabel() {

        const pays = this.pays || 'non défini';
        const typeClient = this.typeClient || 'non défini';

        return `Sélectionnez un Transporteur (${pays} : Client ${typeClient})`;
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
