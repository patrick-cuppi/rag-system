"use client";

import { useState, useRef, useEffect } from 'react';
import { Send, Bot, User, Sparkles } from 'lucide-react';
import { chatWithAskMe } from '../services/api';

type Message = {
  role: 'user' | 'assistant';
  content: string;
};

export default function ChatArea() {
  const [messages, setMessages] = useState<Message[]>([
    { role: 'assistant', content: 'Hello! I am your AI Knowledge Assistant. Upload some documents and ask me anything about them.' }
  ]);
  const [input, setInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages, isTyping]);

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim()) return;

    const userMsg = input.trim();
    setInput('');
    setMessages(prev => [...prev, { role: 'user', content: userMsg }]);
    setIsTyping(true);

    try {
      const data = await chatWithAskMe(userMsg);
      setMessages(prev => [...prev, { role: 'assistant', content: data.answer }]);
    } catch (error) {
      console.error('Chat error:', error);
      setMessages(prev => [...prev, { role: 'assistant', content: 'Sorry, I encountered an error while trying to answer your question.' }]);
    } finally {
      setIsTyping(false);
    }
  };

  return (
    <main className="flex-1 flex flex-col relative bg-gradient-to-b from-[#09090b] to-[#0f0f13]">
      {/* Mobile Header */}
      <header className="md:hidden p-4 border-b border-white/10 flex items-center gap-3 bg-[#09090b]/80 backdrop-blur-md sticky top-0 z-20">
        <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center">
          <Sparkles className="w-4 h-4 text-white" />
        </div>
        <h1 className="font-bold">Ask me</h1>
      </header>

      {/* Chat Messages */}
      <div className="flex-1 overflow-y-auto p-4 md:p-8 scroll-smooth">
        <div className="max-w-3xl mx-auto flex flex-col gap-8 pb-20">
          {messages.map((msg, idx) => (
            <div key={idx} className={`flex gap-4 ${msg.role === 'user' ? 'flex-row-reverse' : ''} animate-in fade-in slide-in-from-bottom-2 duration-300`}>
              <div className={`w-8 h-8 rounded-full flex items-center justify-center shrink-0 shadow-sm ${
                msg.role === 'user' 
                  ? 'bg-gradient-to-br from-slate-700 to-slate-800' 
                  : 'bg-gradient-to-br from-indigo-500 to-purple-600 shadow-indigo-500/20'
              }`}>
                {msg.role === 'user' ? <User className="w-4 h-4 text-white/80" /> : <Bot className="w-4 h-4 text-white" />}
              </div>
              
              <div className={`px-5 py-4 rounded-2xl max-w-[85%] leading-relaxed shadow-sm ${
                msg.role === 'user'
                  ? 'bg-[#27272a] text-white/90 rounded-tr-sm border border-white/5'
                  : 'bg-white/5 text-white/90 rounded-tl-sm border border-white/10'
              }`}>
                {msg.content.split('\n').map((line, i) => (
                  <p key={i} className="mb-2 last:mb-0">{line}</p>
                ))}
              </div>
            </div>
          ))}
          
          {isTyping && (
            <div className="flex gap-4 animate-in fade-in duration-300">
              <div className="w-8 h-8 rounded-full bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center shrink-0 shadow-lg shadow-indigo-500/20">
                <Bot className="w-4 h-4 text-white" />
              </div>
              <div className="px-5 py-4 rounded-2xl bg-white/5 rounded-tl-sm border border-white/10 flex items-center gap-2">
                <span className="w-1.5 h-1.5 bg-indigo-400 rounded-full animate-bounce [animation-delay:-0.3s]"></span>
                <span className="w-1.5 h-1.5 bg-indigo-400 rounded-full animate-bounce [animation-delay:-0.15s]"></span>
                <span className="w-1.5 h-1.5 bg-indigo-400 rounded-full animate-bounce"></span>
              </div>
            </div>
          )}
          <div ref={messagesEndRef} />
        </div>
      </div>

      {/* Input Area */}
      <div className="p-4 md:p-6 bg-gradient-to-t from-[#09090b] via-[#09090b] to-transparent absolute bottom-0 w-full left-0">
        <div className="max-w-3xl mx-auto relative">
          <form onSubmit={handleSendMessage} className="relative flex items-center">
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="Ask me anything about your documents..."
              className="w-full bg-[#27272a]/80 backdrop-blur-md border border-white/10 rounded-2xl pl-6 pr-14 py-4 text-white placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 focus:border-indigo-500/50 transition-all shadow-lg shadow-black/20"
            />
            <button
              type="submit"
              disabled={!input.trim() || isTyping}
              className="absolute right-2 p-2.5 bg-indigo-500 hover:bg-indigo-600 disabled:bg-white/10 disabled:text-white/30 text-white rounded-xl transition-colors disabled:cursor-not-allowed"
            >
              <Send className="w-5 h-5" />
            </button>
          </form>
          <p className="text-center text-xs text-white/30 mt-3">
            AI Knowledge System can make mistakes. Verify important information.
          </p>
        </div>
      </div>
    </main>
  );
}
