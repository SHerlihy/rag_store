const init = `subgraph init [init]
     initProdCon{"\`
         principal:user prod
     \`"}
     
     initProdCon -- true --> initProdAllow
     
     initProdAllow("\`
         sts:AssumeRole
     \`")
     

     initCon{"\`
         principal:oidc-provider
         repo:SHerlihyDotCom
         branch:main
     \`"}
     
     initCon -- true --> initActionsAllow

     initActionsAllow("\`
         sts:AssumeRoleWithWebIdentity
     \`")

     initAllow("\`
         iam:*
         organizations:DescribeAccount
         organizations:DescribeOrganization
         organizations:DescribeOrganizationalUnit
         organizations:DescribePolicy
         organizations:ListChildren
         organizations:ListParents
         organizations:ListPoliciesForTarget
         organizations:ListRoots
         organizations:ListPolicies
         organizations:ListTargetsForPolicy
     \`")
 end
`

export default init
