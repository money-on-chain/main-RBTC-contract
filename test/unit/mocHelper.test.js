const chai = require('chai');

const { expect } = chai;

const testHelperBuilder = require('../mocHelper.js');

let mocHelper;

contract('Unit Test: Moc Helper', async function([owner]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
  });
  it('assertBigRBTC exact', function() {
    mocHelper.assertBigRBTC('10000000000000000000', 10);
  });
  it('assertBigRBTC works with significant digits up', function() {
    mocHelper.assertBigRBTC('10000000000000000001', 10, undefined, { significantDigits: 18 });
  });
  it('assertBigRBTC works with significant digits bellow', function() {
    mocHelper.assertBigRBTC('9999999999999999999', 10, undefined, { significantDigits: 18 });
  });
  it('assertBigRBTC works with satoshis', function() {
    mocHelper.assertBigRBTC('1', 0.000000000000000001);
  });
  it('assertBigRBTC works with low significant digits up', function() {
    mocHelper.assertBigRBTC('11', 0.000000000000000012, undefined, { significantDigits: 1 });
  });
  it('assertBigRBTC works with low significant digits bellow', function() {
    mocHelper.assertBigRBTC('20', 0.000000000000000019, undefined, { significantDigits: 1 });
  });
  it('assertBigDollar works with one digit approximation', function() {
    mocHelper.assertBigDollar('2630016000000000', 0.002629872, undefined, {
      significantDigits: 4
    });
  });
  it('assertBigDollar works with one digit approximation extreme', function() {
    mocHelper.assertBigDollar('9999999999999999', 0.01, undefined, { significantDigits: 15 });
  });
  it('assertBigDollar works with exactly the digits told - not less', async function() {
    expect(function() {
      mocHelper.assertBigDollar('9999999999999999', 0.01, undefined, {
        significantDigits: 17
      });
    }).to.throw(Error);
  });
  it('assertBigRBTC works with the significant digits set-not less', function() {
    expect(function() {
      mocHelper.assertBigRBTC('10000000000000000001', 10, undefined, { significantDigits: 20 });
    }).to.throw(Error);
  });
});
