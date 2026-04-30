"use client";

import { useState } from 'react';
import Sidebar from '../components/Sidebar';
import ChatArea from '../components/ChatArea';

export default function Home() {
  const [activeConversationId, setActiveConversationId] = useState<number | null>(null);

  return (
    <div className="flex h-screen bg-[#09090b] text-[#fafafa] font-sans selection:bg-indigo-500/30 overflow-hidden">
      <Sidebar activeConversationId={activeConversationId} onSelectConversation={setActiveConversationId} />
      <ChatArea activeConversationId={activeConversationId} onConversationCreated={setActiveConversationId} />
    </div>
  );
}
