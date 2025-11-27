const resourcePolicies = `
subgraph bucketDeny
bucketDenyCond{"\`
    createRole
\`"}

bucketDenyRes --> bucketDenyCond
bucketDenyCond -- false --x bucketDenyDeny

bucketDenyDeny("\`
        s3:Delete
        s3:Put
\`")

bucketDenyRes("\`
    createdS3Bucket
\`")

objDenyCond{"\`
    createRole
    replaceRole
\`"}

objDenyRes --> objDenyCond
objDenyCond -- false --x objDenyDeny

objDenyDeny("\`
        s3:Delete
        s3:Put
\`")

objDenyRes("\`
    bucketObject
\`")
end

bucketDeny --> bucketAllow

subgraph bucketAllow
bucketAllowRes("\`
    createdS3Bucket
    bucketObject
\`")

bucketAllowRes --> bucketAllowAllow

bucketAllowAllow("\`
    s3:Get
    s3:List
\`")
end
`

export default resourcePolicies
