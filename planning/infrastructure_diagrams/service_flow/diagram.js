const serviceFlow = `
    flowchart LR

    Client <--> API
    
    subgraph GRP[Get Role Policy]
        subgraph GRPAllow[Allow]
            GetIds[lambda > s3:GetObject]
        end
    end
    
    
    subgraph AWS
    subgraph global
        subgraph LAIM[Lambda IAM]
            subgraph GRP[Get Role Policy]
                subgraph GRPAllow[Allow]
                    GetIds[lambda > s3:GetObject]
                end
            end
    
            subgraph LRP[Lambda Resource Policy]
                subgraph LRPAllow[Allow]
                    APILambda["API > lambda:InvokeFunction"]
                end
            end

        end
    
        GRP -.- List
        GRP -.- Get
        
        Bucket -.-> GetIds
        
        
        LRP -.- List
        LRP -.- Get
        LRP -.- Upload
        LRP -.- Delete
        
        API -.-> APILambda

        API{API Gateway}
        Auth[authoriser lambda]
        
        API <--> Auth

        API <-- GET: / --> List
        API <-- GET: /?ids=[ids] --> Get
        API <-- POST: / --> Upload
        API <-- DELETE: /?ids=[ids] --> Delete

        subgraph region
            subgraph authorised
                List[Get all IDs]
                Get[Get by IDs]
                Upload[Upload single]
                Delete[Delete by IDs]
            end

            Bucket[S3 Bucket]

            List <--> Bucket
            Get <--> Bucket
            Upload <--> Bucket
            Delete <--> Bucket
        end
    end
    end
`

export default serviceFlow
