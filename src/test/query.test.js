const QUERY_URL = "https://mc4mepqu58.execute-api.us-east-1.amazonaws.com/prod/query"

const markStoryRequest = async (story) => {
    return await fetch(QUERY_URL, {
        method: "POST",
        headers: {
            'Content-Type': 'application/json'
        },
        mode: "cors",
        body: story
    })
}

const paragraph = "\
The ballroom of Blackwood Manor hadn’t seen a living guest in eighty years. To the villagers in the valley, it was a hollow ribcage of stone and rot. But to Elara, standing in the center of the dust-choked floor, it pulsed with a faint, rhythmic heartbeat.\
She adjusted the silver locket at her throat. It was cold—a sign he was close.\
\"You’re late, Julian,\" she whispered. Her voice didn't echo; the heavy velvet curtains, gray with age, seemed to swallow the sound.\
"


const chapter = "\
The ballroom of Blackwood Manor hadn’t seen a living guest in eighty years. To the villagers in the valley, it was a hollow ribcage of stone and rot. But to Elara, standing in the center of the dust-choked floor, it pulsed with a faint, rhythmic heartbeat.\
\
She adjusted the silver locket at her throat. It was cold—a sign he was close.\
\
\"You’re late, Julian,\" she whispered. Her voice didn't echo; the heavy velvet curtains, gray with age, seemed to swallow the sound.\
\
A chill wind swept through the room, though the windows were boarded shut. Then, the air began to shimmer. Like ink dropped into water, the shadows coalesced, swirling into the tall, translucent figure of a man in a high-collared frock coat. He didn't just appear; he bled into reality.\
\
Julian Thorne. The Ghost of Blackwood.\
\
His eyes were the color of a winter dawn—pale, piercing, and heartbreakingly sad. He stood a few feet away, his form flickering like a candle flame in a draft.\
\
\"Time is a different currency for me, Elara,\" he said. His voice was a resonant hum that she felt in her marrow rather than heard with her ears. \"To wait for you is the only way I know I still exist.\"\
A Fragile Connection\
\
Elara took a step forward. \"I found the ledger. The one your uncle hid. It proves you weren't the one who broke the seal.\"\
\
Julian’s expression softened, a ghost of a smile touching his lips. He reached out, his hand hovering inches from her cheek. Elara could feel the static electricity, the strange, numbing cold that radiated from his skin.\
\
\"It doesn't change the tether,\" Julian murmured. \"I am bound to these stones, and you... you are bound to the sun. You shouldn't be here, breathing in this graveyard air.\"\
\
\"I don't care about the sun,\" Elara countered, her heart thudding against her ribs. \"I care about the man the world forgot.\"\
The Impossible Dance\
\
Suddenly, the silence was broken. A phantom melody began to play—the ghostly strains of a violin, thin and scratching, as if coming from a music box buried miles underground.\
\
\"Do you hear it?\" Julian asked, his eyes widening.\
\
\"The music?\"\
\
\"The memory,\" he corrected. He bowed low, a courtly gesture from a century long dead. \"They are playing our song, Elara. Or rather, the song that should have been ours.\"\
\
Elara reached out, her fingers passing through his hand like smoke before settling on a layer of resistance—a strange, magnetic push that allowed them to touch without truly meeting.\
\
    The First Step: She felt the temperature drop to freezing.\
\
    The Turn: The dust on the floor swirled around their feet, kicked up by feet that didn't truly touch the ground.\
\
    The Hold: Julian pulled her closer. For a fleeting second, the translucence of his chest thickened, turning into solid, warm muscle through the sheer force of his will.\
\
They moved in a slow, spectral waltz. For a moment, the rot of the manor vanished. The chandeliers blazed with phantom fire, and the gold leaf on the walls glowed. Elara pressed her head against his shoulder. He smelled of rain and old books—the scent of a life interrupted.\
\
\"Stay,\" she breathed.\
\
\"I cannot,\" Julian whispered into her hair, his form beginning to thin as the moon passed behind a cloud. \"The dawn is a thief, Elara. It steals me back from you every time.\"\
\
As the first gray light of morning touched the floorboards, Julian began to dissolve. Elara’s arms fell through empty air. The warmth vanished, replaced by the biting dampness of a ruined house.\
\
He was gone, leaving only a single, frost-covered rose on the floor where he had stood."

describe("paragraph", () => {
    const text = paragraph
    test("only { }", async () => {
        const response = await markStoryRequest(text)

        const marked = await response.text()
        const demarked = marked.replace(/\{|\}/g, "")

        expect(demarked).toMatch(text)
    })

    test("max 1 mark per paragraph", async () => {
        const response = await markStoryRequest(text)

        const marked = await response.text()
        const demarked = marked.replace(/\{|\}/, "")

        expect(demarked).toMatch(text)
    })
})

describe("chapter", () => {
    const text = chapter
    test("only { }", async () => {
        const response = await markStoryRequest(text)

        const marked = await response.text()
        const demarked = marked.replace(/\{|\}/g, "")

        expect(demarked).toMatch(text)
    })

    test("max 1 mark per paragraph", async () => {
        const paragraphArr = toParagraphs(text)

        const eoParagraph = ""
        const paraText = paragraphArr.join(eoParagraph)

        const response = await markStoryRequest(paraText)
        const marked = await response.text()

        const paraMarked = marked.split(eoParagraph)

        paraMarked.forEach((para, i) => {
            const demarked = para.replace(/\{|\}/, "")
            expect(demarked).toMatch(paragraphArr[i])
        })
    })
})

const story = ""
describe("story", () => {
    const text = story
    test("only { }", async () => {
        const response = await markStoryRequest(text)

        const marked = await response.text()
        const demarked = marked.replace(/\{|\}/g, "")

        expect(demarked).toMatch(text)
    })

    test("max 1 mark per paragraph", async () => {
        const paragraphArr = toParagraphs(text)

        const eoParagraph = ""
        const paraText = paragraphArr.join(eoParagraph)

        const response = await markStoryRequest(paraText)
        const marked = await response.text()

        const paraMarked = marked.split(eoParagraph)

        paraMarked.forEach((para, i) => {
            const demarked = para.replace(/\{|\}/, "")
            expect(demarked).toMatch(paragraphArr[i])
        })
    })
})
