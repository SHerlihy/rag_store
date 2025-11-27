import {diagramToMd} from "./diagramToMd.ts"
import serviceFlow from "./service_flow/diagram.js"

diagramToMd(serviceFlow, "./service_flow/description.md")
