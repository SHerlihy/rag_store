const createDist = `subgraph distCreate
    dcaEnable("\`
        sts:AssumeRole
        sts:GetCallerIdentity
        iam:*
    \`")

    dcaACMRes{"\`
        acm:*
    \`"}
    
    dcaACMRes --> dcaACMAllow
    
    dcaACMAllow("\`
        acm:*
    \`")

    dcCDNRes{"\`
        cloudfront:*
    \`"}
    
    dcCDNRes --> dcCDNAllow
    
    dcCDNAllow("\`
        cloudfront:*
    \`")

    dcR53Allow("\`
        route53:*
        route53domains:*
        route53resolver:*
    \`")

end
`

export default createDist
