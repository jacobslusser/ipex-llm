# print some info
echo "TZ=$TZ"
echo "OLLAMA_PORT=$OLLAMA_PORT"
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

# generate Modelfile
echo "FROM $OLLAMA_MODELPATH" > Modelfile

# init ollama first
mkdir -p /llm/ollama
cd /llm/ollama
init-ollama
export OLLAMA_NUM_GPU=999
export ZES_ENABLE_SYSMAN=1
export OLLAMA_HOST=0.0.0.0:$OLLAMA_PORT

# start ollama service in the background
echo "Starting Ollama server..."
(./ollama serve > ollama.log) &

# ensure server has started
while ! curl -s -o /dev/null http://localhost:$OLLAMA_PORT; do
    sleep 0.5
done

# create our model
echo "Creating model..."
./ollama create '$OLLAMA_MODELNAME' -f Modelfile

# tail the ollama log
echo "Ollama server started; model created. Tailing log..."
exec tail -f ollama.log
