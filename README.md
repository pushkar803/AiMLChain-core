## Set Variables

    SSH_KEY=~/aws/shahid-ec2.pem

## On Server

Connect server
ssh -i $SSH_KEY ubuntu@ec2-16-16-96-218.eu-north-1.compute.amazonaws.com && cd ~/poc4/AiMLChain-core

Check if chain is running using
tmux ls

It should show running session named `ai_blockachain_poc_session` \
If not rnning then start chain using
./fast_run.sh

Wait until chain successfully starts

## On Local

Make sure that node version is >= 16

    node -v

If not use nvm to switch node version

    nvm use 16

Install truffle globally if not exist

    npm i -g truffle

Set node code dir
NODE_CODE=~/ipfs

Clone node code

    cd $NODE_CODE
    git clone https://github.com/pushkar803/AiMLChain-core.git && cd ./AiMLChain-core
    npm i

Get copiled contracts and chain data
    
    scp -r -i $SSH_KEY ubuntu@16.16.96.218:~/poc4/AiMLChain-core/build/contracts $NODE_CODE/AiMLChain-core/build

Create local node for that chain

    cd $NODE_CODE/AiMLChain-core && node ./AiMLChain_server 5

Create new terminal and connect to truffle console

    npx truffle console

Instanciate contract
const instance = await UsingAiMLChain.deployed()

Invoke contract method

    await instance.requestPrediction(1, "QmSmY8yhnfiwdedCjguHi28MesHh2CCeCBXrvhzBpaneVA", 0)

Block explorer link

    http://16.16.96.218:5051

give input for block explorer UI as http://16.16.96.218:8545
