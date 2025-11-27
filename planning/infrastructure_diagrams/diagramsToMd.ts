import {diagramToMd} from "./diagramToMd.ts"
import iamPolicies from "./iam_policies/diagram.js";
import serviceFlow from "./service_flow/diagram.js"

diagramToMd(iamPolicies, "./iam_policies/description.md")
diagramToMd(serviceFlow, "./service_flow/description.md")
