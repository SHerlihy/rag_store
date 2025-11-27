const createS3 = `subgraph create [create]
    subgraph createAllow
    createEnable("\`
        iam:*
        sts:AssumeRole
        sts:GetCallerIdentity
    \`")
    createCreate("\`
        s3:Create
        s3:Delete
        s3:Get
        s3:List
        s3:Put
    \`")
    end
end

create --- bucketDeny
`

export default createS3
