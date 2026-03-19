import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTransporters from '@salesforce/apex/OrderTarifService.getOrderTarifs';
import createLivraison from '@salesforce/apex/OrderService.createLivraison';
import getLivraisonByOrder from '@salesforce/apex/OrderService.getLivraisonByOrder';
import updateLivraison from '@salesforce/apex/OrderService.updateLivraison';
import deleteLivraison from '@salesforce/apex/OrderService.deleteLivraison';
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
    getLivraisonByOrder({ orderId: this.recordId })
        .then(result => {
            this.livraison = result;
            this.hasLivraison = result != null;
        });
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
        createLivraison({ orderId: this.recordId, selectedTarificationId: this.selectedTarificationId })
            .then(result => {
                this.livraison = { Id: result };
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
        livraisonId: this.livraison.Id,
        newTarificationId: this.selectedTarificationId
    })
    .then((newLivraisonId) => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Succès',
                message: 'Livraison mise à jour avec succès !',
                variant: 'success'
            })
        );

        // Recharger la livraison avec le nouvel ID
        return getLivraisonByOrder({ orderId: this.recordId });
    })
    .then(result => {
        this.livraison = result;
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

    
    handleDelete() {
        deleteLivraison({ orderId: this.recordId })
            .then(() => {
                this.hasLivraison = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Succès',
                        message: 'Livraison supprimée avec succès!',
                        variant: 'success'
                    })
                );
                 // Redirection vers la liste des Orders
                this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Order',
                    actionName: 'list'
                }
            });
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erreur',
                        message: 'Erreur lors de la suppression de la livraison: ' + (error.body?.message || error.message),
                        variant: 'error'
                    })
                );
            });
    }



  
}
