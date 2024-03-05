#!/bin/bash


nvm_version=$(nvm --version 2>/dev/null)

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "NVM is installed. Version: $nvm_version"
else
    echo "NVM is not installed or not found in the PATH."
fi

NODE_VERSION=$(node -v)
MAJOR_VERSION=$(echo "$NODE_VERSION" | cut -d. -f1 | sed 's/v//')
if [ "$MAJOR_VERSION" -eq 16 ]; then
    echo "2. Node.js version is 16."
else
    echo "2. Node.js version is not 16. It is version $MAJOR_VERSION. so switching to node 16 using nvm"
    nvm use 16
fi

sleep 5

if command -v npx >/dev/null 2>&1; then
    echo "3. npx is already installed."
else
    echo "3. npx is not installed. Installing it now."
    if command -v npm >/dev/null 2>&1; then
        npm install -g npm@latest
        echo "3.1 npx has been installed."
    else
        echo "3.1 npm is not installed. Please install npm first."
    fi
fi

if command -v tmux >/dev/null 2>&1; then
    echo "4. tmux is installed."
else
    echo "4. tmux is not installed."
fi

package_name='ganache-cli'
if [[ "$(npm list -g $package_name)" =~ "empty" ]]; then
    echo "5. $package_name not found so Installing $package_name ..."
    npm install -g $package_name
else
    echo "5. $package_name is already installed"
fi

package_name='truffle'
if [[ "$(npm list -g $package_name)" =~ "empty" ]]; then
    echo "6. $package_name not found so Installing $package_name ..."
    npm install -g $package_name
else
    echo "6. $package_name is already installed"
fi

SESSION_NAME="ai_blockachain_poc_session"
WINDOW_NAME="ai_blockachain_poc_window"
CODE_DIR=~/ipfs/AiMLChain-core

echo "7. killing existing tmux if exists."
tmux kill-session -t $SESSION_NAME

echo "8. creating tmux."
tmux new-session -d -s $SESSION_NAME -n $WINDOW_NAME -x- -y-  -e "CODE_DIR=$CODE_DIR"

tmux split-window -v

tmux select-pane -t 0
tmux split-window -h

tmux select-pane -t 1
tmux split-window -v 

tmux select-pane -t 3
tmux split-window -h 

tmux select-pane -t 3
tmux split-window -v

tmux select-pane -t 5
tmux split-window -v   

tmux select-pane -t 3

tmux send-keys -t ${SESSION_NAME}:${WINDOW_NAME}.0 'cd $CODE_DIR && nvm use 16' C-m
tmux send-keys -t ${SESSION_NAME}:${WINDOW_NAME}.1 'cd $CODE_DIR && nvm use 16' C-m
tmux send-keys -t ${SESSION_NAME}:${WINDOW_NAME}.2 'cd $CODE_DIR && nvm use 16' C-m
tmux send-keys -t ${SESSION_NAME}:${WINDOW_NAME}.3 'cd $CODE_DIR && nvm use 16' C-m
tmux send-keys -t ${SESSION_NAME}:${WINDOW_NAME}.4 'cd $CODE_DIR && nvm use 16' C-m
tmux send-keys -t ${SESSION_NAME}:${WINDOW_NAME}.5 'cd $CODE_DIR && nvm use 16' C-m
tmux send-keys -t ${SESSION_NAME}:${WINDOW_NAME}.6 'cd $CODE_DIR && nvm use 16' C-m
sleep 5

echo "9. creating blockchain using ganache."
tmux send-keys -t ${SESSION_NAME}:${WINDOW_NAME}.0 'ganache-cli -m hawk couple problem quantum lemon lava saddle swallow want become forum educate -l 10000000 --host 0.0.0.0' C-m
sleep 3

echo "10. contract building and migrating through truffle."
tmux send-keys -t ${SESSION_NAME}:${WINDOW_NAME}.1 'npx truffle migrate' C-m
sleep 15

echo "11. starting 5 nodes."
tmux send-keys -t ${SESSION_NAME}:${WINDOW_NAME}.2 'node ./AiMLChain_server 0' C-m
tmux send-keys -t ${SESSION_NAME}:${WINDOW_NAME}.3 'node ./AiMLChain_server 1' C-m
tmux send-keys -t ${SESSION_NAME}:${WINDOW_NAME}.4 'node ./AiMLChain_server 2' C-m
tmux send-keys -t ${SESSION_NAME}:${WINDOW_NAME}.5 'node ./AiMLChain_server 3' C-m
tmux send-keys -t ${SESSION_NAME}:${WINDOW_NAME}.6 'node ./AiMLChain_server 4' C-m

echo "######### Succesfully completed. you can connect to tmux session using tmux attach-session -t $SESSION_NAME ##########"
echo '
    Use following to interact with ML service through contract 
    1. connect to truffle console : 
        npx truffle console
    2. instasiate contract: 
        const instance = await UsingAiMLChain.deployed() 
    3. call contract method: requestPrediction takes input as model id and IPFS hash of input file
        await instance.requestPrediction(1, "QmSmY8yhnfiwdedCjguHi28MesHh2CCeCBXrvhzBpaneVA", 0)
    '
