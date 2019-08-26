#!/bin/sh

create_account() {
  i=1
  while [ $i -le $2 ]
  do
  	address=$(geth account new --datadir $1 --password $passwordPath)
  	i=$((i+1))
  done
}

mineAccounts_Node(){
  i=0
  while [ $i -le $2 ]
  do
    setEtherBaseAccountBool=$(geth --exec 'miner.setEtherbase(eth.accounts['"$i"'])' attach ipc:$1)
  	minerStartBool=$(geth --exec 'miner.start()' attach ipc:$1)
    sleep 1
    minerStopBool=$(geth --exec 'miner.stop()' attach ipc:$1)
  	i=$((i+1))
  done
}

mkdir workspace && cd "$_"

echo "{
  ""\"config"\"": {
  ""\"chainId"\"": 15,
  ""\"homesteadBlock"\"": 0,
  ""\"eip155Block"\"": 0,
  ""\"eip158Block"\"": 0
  },
  ""\"gasLimit"\"": ""\"9000000000000000000"\"",
  ""\"difficulty"\"": ""\"500"\"",
  ""\"alloc"\"": { }
}" > genesis.json

echo "qwerty">password.txt
passwordPath=$(pwd)/password.txt

path1=$(pwd)/node1/geth/nodekey

gethIpc1=$(pwd)/node1/geth.ipc
gethIpc2=$(pwd)/node2/geth.ipc
echo $gethIpc1

$(mkdir node1;geth init genesis.json --datadir node1)
$(mkdir node2;geth init genesis.json --datadir node2)

create_account node1 $1
create_account node2 $1

gnome-terminal --title="Node1" -p -- geth console --datadir node1 --networkid 1729| gnome-terminal --title="Node2" -p -- geth console --datadir node2 --networkid 1729 --port 30304

sleep 3
enodeNode1=$(bootnode -nodekey $path1 -writeaddress)
echo $enodeNode1

enodeWithIP=""\"enode://${enodeNode1}@127.0.0.1:30303"\""
echo $enodeWithIP

addPeerBoolValue=$(geth --exec 'admin.addPeer('"$enodeWithIP"')' attach ipc:$gethIpc2)
echo $addPeerBoolValue

# to add ether to accounts call the mineAccounts_Node function
# mineAccounts_Node $gethIpc1 $1
# mineAccounts_Node $gethIpc2 $1
