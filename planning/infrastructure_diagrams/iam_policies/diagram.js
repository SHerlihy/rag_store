import resourcePolicies from "./diagramComponents/resource_policies/index.js"
import rolePolicies from "./diagramComponents/role_policies/index.js"
import userPolicies from "./diagramComponents/user_policies/index.js"

const iamPolicies = `
    flowchart LR

    ${rolePolicies}
    ${resourcePolicies}
    ${userPolicies}
`

export default iamPolicies
