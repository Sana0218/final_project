class GeminiCorrectionService
def initialize(content)
  @content = content
end

def call
  client = OpenAI::Client.new(
    access_token: ENV['GEMINI_API_KEY'],
    uri_base: 'https://generativelanguage.googleapis.com/v1beta/openai/'
  )
  response = client.chat(parameters: {
    response_format: { type: "json_object" },
    model: "gemini-3.6-flash",
    messages: [
      { role: "system", content: "You are a helpful assistant that corrects the spelling and grammar of the user's text. Return the response in JSON format with the following keys: corrected_text and feedback. corrected_text is the corrected text, feedback is the feedback in Japanese." },
      { role: "user", content: @content }
    ]
  })

  text = response.dig('choices', 0, 'message', 'content')
  parsed_response = JSON.parse(text)
  {
    corrected_text: parsed_response["corrected_text"],
    feedback: parsed_response["feedback"]
  }

end 
end