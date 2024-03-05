const IPFS = require("nano-ipfs-store");
const ipfs = IPFS.at("http://localhost:5001");
const assert = require("assert");

(async () => {

  // Upload raw data
  const data1 = new Uint8Array([0,1,3,7,15,31,63,127,255]);
  const cid1 = await ipfs.add(data1);

  // Recover it from returned CID
  const data2 = await ipfs.get(cid1);
  assert(JSON.stringify(data1) === JSON.stringify(data2));

//   // Generate CID without uploading
//   const cid2 = await ipfs.cid(data1);
//   assert(cid1 === cid2);

  // Upload string
  assert(await ipfs.cat(await ipfs.add("foobar")) === "foobar");

  console.log("ok");

  cid3 = "QmSmY8yhnfiwdedCjguHi28MesHh2CCeCBXrvhzBpaneVA"
  ipfs.cat(cid3).then((data)=>{
    console.log(data)
  }).catch((error) => {
    console.error(error);
  });;
  

  shash = await ipfs.add("foobar111")
  console.log(shash)

})();
