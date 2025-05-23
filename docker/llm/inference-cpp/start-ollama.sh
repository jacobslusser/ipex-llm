# print some info
echo "TZ=$TZ"
echo "OLLAMA_HOST=$OLLAMA_HOST"
echo "OLLAMA_MODELPATH=$OLLAMA_MODELPATH"
echo "OLLAMA_MODELNAME=$OLLAMA_MODELNAME"
echo ""
echo "GPU info (sycl-ls):"
sycl-ls
echo ""

# set timezone
if [ -n "$TZ" ]; then
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
    echo $TZ > /etc/timezone
    dpkg-reconfigure -f noninteractive tzdata > /dev/null 2>&1 || true
fi

# init ollama first
mkdir -p /llm/ollama
cd /llm/ollama
init-ollama
export OLLAMA_NUM_GPU=999
export ZES_ENABLE_SYSMAN=1

# import the model
echo "FROM $OLLAMA_MODELPATH" > Modelfile
# ./ollama create '$OLLAMA_MODELNAME' -f Modelfile

# start ollama service
# echo "Starting Ollama server..."
# exec ./ollama serve

# testing
exec /bin/bash
