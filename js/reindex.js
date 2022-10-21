export let allItems = async () => {
  const response = await fetch('/current-checkouts/u-m-library/all')  
  return await response.json();
};


export const Items = class {
  constructor(items){
    this.items = items
  }

  eligible() {
    return this.items.filter((item) => {
      return item.renewable;
    })
  }

  //not working
  //async renewAllEligible(){
    //return (this.eligible().map((item) =>{
      //return await this.renewOneLoan(item.loan_id);
    //}));
  //}
  async renewOneLoan (loanID) {
    const response = await fetch(`/renew-loan?loan_id=${loanID}`, { method: 'POST' });
    return await response.json();
  }

  static async fetchItems()  {
    const response = await fetch('/current-checkouts/u-m-library/all')  
    const results = await response.json();
    return new Items(results); 
  }
}

export const ProgressBar = class {
  constructor(element){
    this.progress = element.querySelector('progress');
    //this.progressDescription = this.progress.querySelector('#progress-description');
    //this.progressDescriptionRenewed = this.progressDescription.querySelector('.renewed-loans');
    //this.progressDescriptionTotal = this.progressDescription.querySelector('.total-loans');
    this.progressLabel = element.querySelector('#progress-label')
  }
  setLabel(text){
    this.progressLabel.textContent = text;
  }

}
   
export const setProgressBar = (progressBar, label) => {
  progressBar.querySelector("h3").textContent = label;  
}
