import init from "./init.js"
import createDist from "./create_dist.js"
import createS3 from "./create_S3.js"
import replaceS3 from "./replace_S3.js"

const rolePolicies = `
    ${init}
    ${createDist}
    ${createS3}
    ${replaceS3}
`

export default rolePolicies
