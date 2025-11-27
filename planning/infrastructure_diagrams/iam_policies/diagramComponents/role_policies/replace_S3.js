const replaceS3 = `subgraph replace [replace]
    subgraph replaceDeny
    replaceDenyRes{"\`
        createdS3Bucket
        bucketObject
    \`"}
    
    replaceDenyRes -- false --> replaceDenyDeny
    
    replaceDenyDeny("\`
        s3:*
    \`")
    
    end
    
    replaceDeny --> replaceRes
    
    replaceRes("\`
        bucketS3 objects
    \`")
    
    replaceRes --> replaceAllow
    
        subgraph replaceAllow
        replaceEnable("\`
            iam:*
            sts:AssumeRole
            sts:GetCallerIdentity
        \`")
        replaceReplace("\`
            s3:Create
            s3:Delete
            s3:Get
            s3:List
            s3:Put
        \`")
    end
end

replace --- bucketDeny
`

export default replaceS3
