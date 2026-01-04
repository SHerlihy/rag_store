const serviceFlow = `
    flowchart LR

    Client <--> STAGE
    
    subgraph GRP[Get Role Policy]
        subgraph GRPAllow[Allow]
            GetIds[lambda > s3:GetObject]
        end
    end

    subgraph AWSIAM[IAM Policies]
        subgraph LAIM[Lambda IAM]
            subgraph URP[Upload Role Policy]
                subgraph URPAllow[Allow]
                    UploadDoc[lambda > s3:PutObject]
                end
            end

            subgraph LRP[Lambda Resource Policy]
                subgraph LRPAllow[Allow]
                    APILambda["API > lambda:InvokeFunction"]
                end
            end
        end
    end
    
    subgraph AWS
    subgraph global

        STAGE[main]
        KBAAS{kbaas}

        PREFLIGHT[preflight]
        
        STAGE --> KBAAS
        
        KBAAS --> PREFLIGHT
        PREFLIGHT --> KBAAS

        KBAAS <--> LIST & PHRASES & QUERY
        PREFLIGHT ~~~ LIST & PHRASES & QUERY

        AUTH[authoriser lambda]

        LIST --> AUTH
        AUTH --> LIST

        PHRASES --> AUTH
        AUTH --> PHRASES
        
        QUERY --> AUTH
        AUTH --> QUERY
        
        subgraph source

            LIST[list]
            PHRASES[phrases]
            
            LIST <-- GET: / --> BUCKET
            PHRASES <-- PUT: / --> OBJECT

            subgraph region_SOURCE

                subgraph bucket
                    BUCKET[S3 Bucket]
                    
                    subgraph objects
                        OBJECT[Phrases Object]
                    end

                end

            end

        end

        subgraph query

            QUERY[query]

            QUERY <-- POST: / --> KB_LAMBDA

            subgraph region_KB

                KB_LAMBDA[knowledge base lambda]
    
            end

        end
    end
    end
`

export default serviceFlow
