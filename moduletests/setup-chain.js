(async () => {
  
  const cp = require('child_process')
  const fs = require('fs')
  const path = require('path')
  const toml = require('@iarna/toml')
  
  if (process.argv.length !== 4) {
    console.error("Usage: " + 
      path.basename(process.argv[0]) + " " + 
      path.basename(process.argv[1]) + " " +
      "<data_dir> " +
      "<config_dir>")
    process.exit(-1)
  }
  
  const DATA=process.argv[2]
  const CONFIG=process.argv[3]
  const KEYS= DATA + "/keys.json"
  
  const config = JSON.parse(fs.readFileSync(CONFIG))
  if (fs.existsSync(KEYS)) {
    var keys = JSON.parse(fs.readFileSync(KEYS))
  } else {
    keys = {}
  }
  keys[config.chain_id] = {}
  
  const CHAINHOME=DATA + "/" + config.executable
  const NODE=config.executable
  
  console.log()
  console.log("Setting up chain: " + config.chain_id)
  await cp.exec("pkill " + config.executable)
  await cp.exec("rm -rf " + CHAINHOME)
  
  const chainexec = cmd => {
    const cmdstring = config.executable + " --home " + CHAINHOME + " " + cmd
    console.log("  $ " + cmd)
    const bufs = cp.spawnSync(config.executable, [
      "--home " + CHAINHOME,
      cmd
    ],{
      shell: true
    })
    if (bufs.status !== 0) {
      console.error("Command failed: " + cmdstring)
      process.exit(-1)
    }
    const ret = {
      stdout: bufs.stdout.toString(),
      stderr: bufs.stderr.toString()
    }
    return ret
  }
  
  const addkey = async name => {
    let output = await chainexec("keys add " + name + " --output json --keyring-backend test")
    let key = JSON.parse(output.stdout)
    keys[config.chain_id][name] = {
      address: key.address,
      pubkey: key.pubkey,
      mnemonic: key.mnemonic
    }
  }
  
  const fundAcct = async (acct, coins) => {
    await chainexec("add-genesis-account " + acct + " " + coins + " --keyring-backend test")
  }
  
  // init
  await chainexec("init " + NODE + " --chain-id " + config.chain_id)
  
  // add keys
  const names = Object.keys(config.keys)
  for (var i=0; i<names.length; i++) {
    //console.log("generating key: " + names[i])
    await addkey(names[i])
    // fund account
    //console.log("funding account: " + names[i] + " " + config.keys[names[i]])
    await fundAcct(names[i], config.keys[names[i]])
  }
  
  // add external accounts
  if (config.external !== undefined) {
    const external = Object.keys(config.external)
    for (i=0; i<external.length; i++) {
      // fund account
      //console.log("funding account: " + external[i] + " " + config.external[external[i]])
      await fundAcct(external[i], config.external[external[i]])
    }
  }
  
  fs.writeFileSync(KEYS, JSON.stringify(keys, null, 2))
  
 function mergeDeep(...objects) {
    const isObject = obj => obj && typeof obj === 'object';
    
    return objects.reduce((prev, obj) => {
      Object.keys(obj).forEach(key => {
        const pVal = prev[key];
        const oVal = obj[key];
        
        if (Array.isArray(pVal) && Array.isArray(oVal)) {
          prev[key] = pVal.concat(...oVal);
        }
        else if (isObject(pVal) && isObject(oVal)) {
          prev[key] = mergeDeep(pVal, oVal);
        }
        else {
          prev[key] = oVal;
        }
      });
      
      return prev;
    }, {});
  }
  
  // Config.toml
  if (config.config !== undefined) {
    let configFile = CHAINHOME + "/config/config.toml"
    let configJSON = toml.parse(fs.readFileSync(configFile))
    configJSON = mergeDeep(configJSON, config.config)
    fs.writeFileSync(configFile, toml.stringify(configJSON))
  }
  
  // App.toml
  if (config.app !== undefined) {
    let appFile = CHAINHOME + "/config/app.toml"
    let appJSON = toml.parse(fs.readFileSync(appFile))
    appJSON = mergeDeep(appJSON, config.app)
    fs.writeFileSync(appFile, toml.stringify(appJSON))
  }
  
  // Genesis.json
  if (config.genesis !== undefined) {
    const genesisFile = CHAINHOME + "/config/genesis.json"
    let genesis = JSON.parse(fs.readFileSync(genesisFile))
    genesis = mergeDeep(genesis, config.genesis)
    fs.writeFileSync(genesisFile, JSON.stringify(genesis, null, 2))
  }

})().catch(e => {
  
  console.error(e)
  
})

