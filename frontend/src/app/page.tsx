import Sidebar from '../components/Sidebar';
import ChatArea from '../components/ChatArea';

export default function Home() {
  return (
    <div className="flex h-screen bg-[#09090b] text-[#fafafa] font-sans selection:bg-indigo-500/30 overflow-hidden">
      <Sidebar />
      <ChatArea />
    </div>
  );
}
