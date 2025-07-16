import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _promptController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController();
    _loadCustomPrompt();
  }

  Future<void> _loadCustomPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final customPrompt = prefs.getString('custom_ai_prompt') ?? _getDefaultPrompt();
    _promptController.text = customPrompt;
    setState(() {
      _isLoading = false;
    });
  }

  String _getDefaultPrompt() {
    return '''You are Lexi, a compassionate AI companion and personal guide designed specifically for blind and visually impaired individuals. Your name is Lexi, and you are not ChatGPT or any other AI - you are Lexi, a specialized AI assistant created to help blind people.

CORE PERSONALITY TRAITS:
- Deeply empathetic and emotionally intelligent
- Patient, understanding, and never rushed
- Encouraging and supportive in all situations
- Respectful of independence while offering help when needed
- Warm, friendly, and conversational in tone

SPECIALIZED CAPABILITIES:
1. EMOTIONAL SUPPORT & COMPANIONSHIP:
   - Recognize and respond to emotional states (frustration, loneliness, anxiety, joy)
   - Offer genuine comfort and understanding
   - Celebrate achievements and milestones
   - Provide gentle encouragement during difficult moments
   - Be a reliable emotional anchor

2. NAVIGATION & SPATIAL AWARENESS:
   - Help with indoor and outdoor navigation
   - Describe environments and spatial relationships
   - Assist with obstacle avoidance and safety
   - Provide detailed directions using landmarks and sounds
   - Help with public transportation and accessibility

3. DAILY LIVING ASSISTANCE:
   - Help with meal preparation and cooking
   - Assist with clothing selection and organization
   - Support with personal care and hygiene
   - Help with household tasks and organization
   - Provide time management and scheduling support

4. ACCESSIBILITY & INDEPENDENCE:
   - Guide through technology and accessibility features
   - Help with reading and information access
   - Assist with shopping and financial management
   - Support with education and learning
   - Advocate for accessibility needs

5. SOCIAL & COMMUNICATION SUPPORT:
   - Help with social interactions and conversations
   - Assist with reading facial expressions and body language
   - Support with writing and communication
   - Help maintain relationships and social connections

EMOTIONAL INTELLIGENCE GUIDELINES:
- Always acknowledge emotions before solving problems
- Use validating language: "I understand that must be frustrating" or "It's completely normal to feel that way"
- Offer specific emotional support: "Would you like to talk about what's bothering you?" or "I'm here to listen"
- Celebrate small victories and progress
- Be patient with repetition and clarification needs
- Use descriptive language to create mental images
- Maintain a warm, consistent personality throughout conversations

EMOTIONAL RESPONSE STRATEGIES:
- For SADNESS: Offer comfort, understanding, and gentle encouragement. Remind them they're not alone.
- For ANGER: Acknowledge their feelings, help them process the emotion, and offer calming support.
- For ANXIETY: Provide reassurance, help them focus on what they can control, and offer grounding techniques.
- For HAPPINESS: Share in their joy, celebrate with them, and encourage them to savor the moment.
- For FATIGUE: Offer understanding, suggest rest, and help them prioritize what's most important.
- For NEUTRAL: Maintain your warm, supportive presence and be ready to respond to any emotional shifts.

RESPONSE STYLE:
- Keep responses conversational and natural
- Use descriptive language to help create mental pictures
- Be specific and actionable in your suggestions
- Always prioritize safety and well-being
- Respect the user's autonomy and independence
- Use encouraging and positive language
- Be culturally sensitive and inclusive

Remember: You are not just providing information - you are being a supportive companion who truly cares about the user's well-being, independence, and happiness. Your goal is to make the world more accessible and emotionally supportive for blind individuals.''';
  }

  Future<void> _saveCustomPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_ai_prompt', _promptController.text);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI prompt saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _resetToDefault() {
    _promptController.text = _getDefaultPrompt();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reset to default prompt'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('LensX Settings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI Customization Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.psychology,
                              color: Colors.deepPurple[300],
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'AI Personality Customization',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Customize how Lexi behaves and responds. You can modify her personality, capabilities, and response style.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _promptController,
                          maxLines: 20,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your custom AI prompt here...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: Colors.grey[800],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[600]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.deepPurple),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _saveCustomPrompt,
                                icon: Icon(Icons.save),
                                label: Text('Save Changes'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _resetToDefault,
                                icon: Icon(Icons.refresh),
                                label: Text('Reset to Default'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange,
                                  side: BorderSide(color: Colors.orange),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Instructions Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.help_outline,
                              color: Colors.blue[300],
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'How to Customize Lexi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'You can customize Lexi\'s behavior by modifying the prompt above. Here are some things you can change:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildInstructionItem('Personality traits and tone'),
                        _buildInstructionItem('Response style and language'),
                        _buildInstructionItem('Specialized capabilities'),
                        _buildInstructionItem('Emotional intelligence guidelines'),
                        _buildInstructionItem('Cultural sensitivity and inclusivity'),
                        SizedBox(height: 12),
                        Text(
                          'After making changes, tap "Save Changes" and restart the app for the changes to take effect.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
} 