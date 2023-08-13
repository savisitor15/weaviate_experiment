#!/usr/bin/env bash
URL_TEXT2VEC='curl -o docker-compose.yml "https://configuration.weaviate.io/v2/docker-compose/docker-compose.yml?generative_cohere=false&generative_openai=false&generative_palm=false&gpu_support=false&media_type=text&modules=modules&ner_module=false&qna_module=false&ref2vec_centroid=false&reranker_cohere=false&runtime=docker-compose&spellcheck_module=false&sum_module=false&text_module=text2vec-transformers&transformers_model=google-flan-t5-base&weaviate_version=v1.20.5"'
URL_QNA='curl -o docker-compose.yml "https://configuration.weaviate.io/v2/docker-compose/docker-compose.yml?generative_cohere=false&generative_openai=false&generative_palm=false&gpu_support=false&media_type=text&modules=modules&ner_module=false&qna_module=false&ref2vec_centroid=false&reranker_cohere=false&runtime=docker-compose&spellcheck_module=false&sum_module=false&text_module=text2vec-transformers&transformers_model=_custom&transformers_model_custom_image=semitechnologies%2Ftransformers-inference%3Asentence-transformers-msmarco-distilbert-base-v2&weaviate_version=v1.20.5"'
SERVICE='weaviate'
OPT=0
PS3="Select option: "

check_service() {
    if [ -z `docker-compose ps -q $SERVICE` ]; then
        return 1
    else
        return 0
    fi
}

start_service() {
    if check_service;then
        kill_service
    fi  
    download_service
    echo "Service starting..."
    docker-compose up -d $SERVICE  
}

download_service() {
    echo "Downloading docker-compose.yml..."
    if [[ $OPT -eq 1 ]];then
        eval $URL_TEXT2VEC
    else
        eval $URL_QNA
    fi
}

kill_service() {
    echo "Shutting down service..."
    # Give the container some time to die
    # Reset SECONDS to act as a timeout check
    SECONDS=0
    until ! check_service
    do
        if (( SECONDS > 1 )); then
            echo "ERROR SHUTTINGDOWN DOCKER CONTAINER FOR $SERVICE"
            exit 1
        fi
        docker-compose down $SERVICE
        sleep 1
    done
}

main() {
    echo "Starting weaviate..."
    select opt in QNA TEXT2VEC; do
        case $opt in
        QNA)
            OPT=0
            echo "QNA Module selected"
            break
        ;;
        TEXT2VEC)
            OPT=1
            echo "TEXT2VEC module selected"
            break
        ;;
        *)
            echo "Invalid option!"
            exit 1
            break
            ;;
        esac
    done
    start_service
}


# Run the main body of the script
main
