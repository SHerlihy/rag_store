import {execSync} from 'child_process';

export const diagramToMd = (dia: string, mdRoute: string) => {
    const modStrForAWK = (str:string):string => {
        const diaSpcSplit = str.split("\n")
        const diaSpcJoin = diaSpcSplit.join("\\n")
        
        const diaCommaSplit = diaSpcJoin.split("\"")
        const diaCommaJoin = diaCommaSplit.join("\\\"")
        
        return diaCommaJoin
    }

    execSync(`awk -i inplace \
        'BEGIN {toPrint = 0};\
        /\`\`\`/ {toPrint = 0};\
        {if (toPrint == 0) print};\
        /\`\`\`mermaid/ {toPrint = 1};'\
        ${mdRoute}`,
        { encoding: 'utf-8' }
    )
    
    const awkStr = modStrForAWK(dia)
    
    execSync(`awk -i inplace\
        '{print};\
        /\`\`\`mermaid/ {print "${awkStr}"};'\
        ${mdRoute}`,
        { encoding: 'utf-8' }
    )
}
