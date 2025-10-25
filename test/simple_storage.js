const SimpleStorage = artifacts.require("SimpleStorage");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("SimpleStorage", function (/* accounts */) {
  it("should assert true", async function () {
    await SimpleStorage.deployed();
    return assert.isTrue(true);
  });
});
