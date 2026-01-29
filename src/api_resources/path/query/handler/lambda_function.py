import json
import os
import re
import asyncio

import boto3

from lambda_utils import Text_To_Sentance_Array

session = boto3.Session()
bedrock = session.client('bedrock')
agent = session.client('bedrock-agent-runtime')

def handler(event, context) -> Respose:
    response = {
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
                },
            'statusCode': 500,
            'body': 'Error on init'
        }

    marked = ''

    to_sentances = Text_To_Sentance_Array(event["body"], 17)
    paragraphs = to_sentances.get_sentances()

    try:
        query_kb = Query_KB()

        marked_list = await asyncio.gather(
            *[query_kb.mark_paragraph(p) for p in paragraphs]
        )

        marked = "".join(marked_list)

    except Exception as err:
        print(err.response)
        response["headers"]["X-Amzn-ErrorType"] = f"{type(err)}"
        response["statusCode"] = 500
        response["body"] = "KB error"
        return response

    response["statusCode"] = 200
    response["body"] = marked
    return response

class Query_KB():
    def __init__(self):
        self.KB_ID = os.environ.get('KB_ID')

        self.agent_profile ='You will be given a Story Paragraph and must mark phrases that sound like they are created by AI. \
        You are only allowed to respond with a marked version of the Story Paragraph. \
        You must mark phrases by enclosing each phrase in braces. \
        The following text, enclosed in square brackets, includes high priority examples of phrases to be marked [$search_results$]. \
        The following text, enclosed in square brackets, is the Story Paragraph for you to return marked [$query$].'
        
        model_id = "amazon.nova-micro-v1:0"
        fm_res = bedrock.get_foundation_model(
            modelIdentifier=model_id
        )

        self.fm_arn = fm_res['modelDetails']['modelArn']

    async def mark_paragraph(self, paragraph):
        inference = agent.retrieve_and_generate(
            input={
                'text': paragraph
            },
            retrieveAndGenerateConfiguration={
                'type': 'KNOWLEDGE_BASE',
                'knowledgeBaseConfiguration': {
                    'knowledgeBaseId': self.KB_ID,
                    'modelArn': self.fm_arn,
                    'retrievalConfiguration': {
                        'vectorSearchConfiguration': {
                            'numberOfResults': 5,
                            'overrideSearchType': 'SEMANTIC',
                        }
                    },
                    'generationConfiguration': {
                        'promptTemplate': {
                            'textPromptTemplate': self.agent_profile,
                        },
                        'inferenceConfig': {
                            'textInferenceConfig': {
                                'temperature': 0.8,
                                'topP': 0.1,
                                'maxTokens': 512,
                                'stopSequences': []
                            }
                        },
                        'performanceConfig': {
                            'latency': 'standard'
                        }
                    }
                }
            }
        )
    
        return inference['output']['text']
