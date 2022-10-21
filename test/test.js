import { expect } from 'chai';
import sinon from 'sinon'
import { allItems, setProgressBar, ProgressBar, Items } from "../js/reindex.js";
import jsdom from 'jsdom'

const { JSDOM } = jsdom;
function jsonOk (body) {
  var mockResponse = new global.Response(JSON.stringify(body), { //the fetch API returns a resolved window Response object
    status: 200,
    headers: {
      'Content-type': 'application/json'
    }
  });
  return Promise.resolve(mockResponse);
}

describe("renew-all-elligible", () => {
  beforeEach(() => {
    const dom = new JSDOM(`<html>
      <body>
      <div class="progress-bar" aria-live="polite" style="display: none;">
        <h3 id="progress-label">Renewing loans...</h3>
        <progress
          value="0"
          max="<%= loans.count %>"
          aria-labelledby="progress-label"
          aria-describedby="progress-description"
          aria-busy="false"
        ></progress>
        <p id="progress-description">
          <span class="renewed-loans">0</span> of <span class="total-loans"><%= loans.count %></span> renewed
        </p>
      </div>
      </body>
      </html>`
    );
    global.window = dom.window
    global.document = dom.window.document;
  });
  it("updates something", () => {
    const pb = document.querySelector(".progress-bar");
    console.log(pb)
    //setProgressBar(progressBar, "some label")
    //expect(progressBar.querySelector("h3").textContent).to.equal("some label");
    let pbsetter = new ProgressBar(pb);
    pbsetter.setLabel("newText")
    expect(pb.querySelector("h3").textContent).to.equal("newText");
  });
});

describe('allItems', () => {
  var server;
  var items_json;
  const dom = new JSDOM(`<!DOCTYPE html><p>Hello world</p>`);
  console.log(dom.window.document.querySelector("p").textContent); // "Hello world"
  
  
  beforeEach(function () {
    server = sinon.stub(global, 'fetch');
    items_json = [
      { loan_id: "111", renewable: true},
      { loan_id: "222", renewable: false}
    ]
  });
  afterEach(function () {
    global.fetch.restore();
  });
  it('should return json from the server', async () => {
    server.withArgs("/current-checkouts/u-m-library/all").returns(jsonOk(items_json));
    const items = await Items.fetchItems();
    expect(items.items).to.eql(items_json)
  });
  it('should return ellibile items', async () => {
    server.withArgs("/current-checkouts/u-m-library/all").returns(jsonOk(items_json));
    const items = await Items.fetchItems();
    expect(items.eligible()).to.eql([{loan_id: "111", renewable: true}]);
  });
  //it ('should renew everything', async() => {
    //server.withArgs("/renew-loan?loan_id=111", {method: 'POST'}).returns(jsonOk({}));
    //const items = await Items.fetchItems();
    //items.renewAllEligible.then(result => {
      //console.log(result)
    //})
  //});
});

