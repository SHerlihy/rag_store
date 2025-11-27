const userPolicies = `subgraph prod [user prod]
    prodEnable("\`
        iam:*
        sts:*
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

prod --> init
prod --> create
prod --> replace
prod --> distCreate
`

export default userPolicies
