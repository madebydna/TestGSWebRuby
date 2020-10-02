import { expect } from 'chai';
import { describe, it } from 'mocha';
import { equal } from 'assert';
import {
  getQueryParam,
  updateUrlParameter,
  updateQueryParams,
} from "components/header/query_param_utils";

// client/app/bundles/GSWeb/components/header/query_param_utils.js
describe('QueryParamUtils', ()=> {
  
  context('#updateUrlParameter', ()=> {

    context('With no query params',()=>{
      let uri = 'https://greatschools.org/';
      let key = 'state';
      let value = 'ca';

      it('inserts in the query param correctly', () => {
        let answer = 'https://greatschools.org/?state=ca'
        expect(updateUrlParameter(uri, key, value)).to.equal(answer);
      })

      it('inserts in the query param correctly with an anchor', () => {
        uri = 'https://greatschools.org/#Reviews'
        let answer = 'https://greatschools.org/?state=ca#Reviews'
        expect(updateUrlParameter(uri, key, value)).to.equal(answer);
      })
    })

    context('With one query params',()=>{
      let uri = 'https://greatschools.org/?city=Los%20Angeles';
      let key = 'state';
      let value = 'ca';

      it('inserts in the query param correctly', () => {
        let answer = 'https://greatschools.org/?city=Los%20Angeles&state=ca'
        expect(updateUrlParameter(uri, key, value)).to.equal(answer);
      })
      
      it('inserts in the query param correctly with an anchor', () => {
        uri = 'https://greatschools.org/?city=Los%20Angeles#Reviews'
        let answer = 'https://greatschools.org/?city=Los%20Angeles&state=ca#Reviews'
        expect(updateUrlParameter(uri, key, value)).to.equal(answer);
      })

      it('remove the query param correctly', () => {
        uri = 'https://greatschools.org/?city=Los%20Angeles'
        key='city'
        value=''
        let answer = 'https://greatschools.org/'
        expect(updateUrlParameter(uri, key, value)).to.equal(answer);
      })

    })

    context('With multiple query params',()=>{
      let uri = 'https://greatschools.org/?city=Los%20Angeles&zipcode=90032';
      let key = 'state';
      let value = 'ca';

      it('inserts in the query param correctly', () => {
        let answer = 'https://greatschools.org/?city=Los%20Angeles&zipcode=90032&state=ca'
        expect(updateUrlParameter(uri, key, value)).to.equal(answer);
      })

      it('inserts in the query param correctly with an anchor', () => {
        uri = 'https://greatschools.org/?city=Los%20Angeles&zipcode=90032#Reviews'
        let answer = 'https://greatschools.org/?city=Los%20Angeles&zipcode=90032&state=ca#Reviews'
        expect(updateUrlParameter(uri, key, value)).to.equal(answer);
      })

      it('remove the query param correctly when its the first pair', () => {
        uri = 'https://greatschools.org/?city=Los%20Angeles&zipcode=90032&state=ca'
        key = 'city'
        value = ''
        let answer = 'https://greatschools.org/?zipcode=90032&state=ca'
        expect(updateUrlParameter(uri, key, value)).to.equal(answer);
      })

      it('remove the query param correctly when its the last pair', () => {
        uri = 'https://greatschools.org/?city=Los%20Angeles&zipcode=90032&state=ca'
        key = 'state'
        value = ''
        let answer = 'https://greatschools.org/?city=Los%20Angeles&zipcode=90032'
        expect(updateUrlParameter(uri, key, value)).to.equal(answer);
      })

      it('remove the query param correctly when its somewhere in the middle', () => {
        uri = 'https://greatschools.org/?city=Los%20Angeles&zipcode=90032&state=ca&sort=name'
        key = 'zipcode'
        value = ''
        let answer = 'https://greatschools.org/?city=Los%20Angeles&state=ca&sort=name'
        expect(updateUrlParameter(uri, key, value)).to.equal(answer);
      })
    })

  })

  context('#getQueryParam', ()=>{
    context('With no query params', () => {
      let uri = 'https://greatschools.org/';
      let key = 'state';

      it('return null when no key is found in its list', () => {
        let answer = null;
        expect(getQueryParam(key, uri)).to.equal(answer);
      })
    })
    context('With multiple query params', () => {
      let uri = 'https://greatschools.org/?city=Los%20Angeles&zipcode=90032&state=ca&sort=name';
      let key = 'state';

      it('return null when no key is found in its list', () => {
        key = 'district';
        let answer = null;
        expect(getQueryParam(key, uri)).to.equal(answer);
      })

      it('return correct params when key is first in the string', () => {
        key = 'city';
        let answer = 'Los%20Angeles';
        expect(getQueryParam(key, uri)).to.equal(answer);
      })
      it('return correct params when key is last in the string', () => {
        key = 'sort';
        let answer = 'name';
        expect(getQueryParam(key, uri)).to.equal(answer);
      })
      it('return correct params when key is in middle of the string', () => {
        key = 'zipcode';
        let answer = '90032';
        expect(getQueryParam(key, uri)).to.equal(answer);
      })
    })

  })

  // context("#updateQueryParams", () => {
  //   let key = 'state';
  //   let value = 'ca';

  //   context("With no query params", ()=>{
  //     let searchParams = "";
  //     let answer = "?state=ca"
  //     it('should return the correct search params', ()=> {
  //       expect(updateQueryParams(searchParams, key, value).to.equal(answer));
  //     })
  //   });
  // });
})