import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getTarifs from '@salesforce/apex/OrderTarifService.getByOrderIds';
import createLivraison from '@salesforce/apex/DeliveryOrderService.createByOrderIds';
import getLivraisonByOrder from '@salesforce/apex/DeliveryOrderService.getByOrderIds';
import updateLivraison from '@salesforce/apex/DeliveryOrderService.updateByIds';

import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
import PAYS_FIELD from '@salesforce/schema/Order.Pays__c';
import TYPE_FIELD from '@salesforce/schema/Order.Account_Type__c';
import { NavigationMixin } from 'lightning/navigation';





export default class TransporterList extends NavigationMixin(LightningElement) {
    @api recordId;
    selectedTarificationId;


    tarifs = [];
    
    hasLivraison = false;

    connectedCallback() {
    getLivraisonByOrder({ orderIds: [this.recordId] })
        .then(result => {
            const livraisons = result[this.recordId];

            if (livraisons && livraisons.length > 0) {
                this.livraison = livraisons[0];
                this.hasLivraison = true;
            } else {
                this.livraison = null;
                this.hasLivraison = false;
            }
            }     
        );
    }

    @wire(getTarifs, { orderId: '$recordId' }) 
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

    get isUpdateDisabled() {
        return !this.selectedTarificationId;
    }

    handleSelection(event) {
        this.selectedTarificationId = event.target.value;
        }
        
    handleCreateLivraison() {
        createLivraison({
            orderIds: [this.recordId],
            selectedTarifIds: { [this.recordId]: this.selectedTarificationId }
        })

        .then(result => {
            const livraisonId = result[this.recordId];

            this.livraison = { Id: livraisonId };
            this.hasLivraison = true;
            this.selectedTarificationId = null;

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


    handleUpdate() {
        updateLivraison({
            deliveryOrderIds: [this.livraison.Id],
            newTarifIds: { [this.livraison.Id]: this.selectedTarificationId }
        })
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Succès',
                    message: 'Livraison mise à jour avec succès !',
                    variant: 'success'
                })
            );

            return getLivraisonByOrder({ orderIds: [this.recordId] });
        })
        .then(result => {
            const livraisons = result[this.recordId];

            if (livraisons && livraisons.length > 0) {
                this.livraison = livraisons[0];
            } else {
                this.livraison = null;
            }

            this.selectedTarificationId = null;
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erreur',
                    message: 'Erreur lors de la mise à jour : ' + (error.body?.message || error.message),
                    variant: 'error'
                })
            );
        });
    }



  
}
