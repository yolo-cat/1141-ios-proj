# iOS DashboardView 設計規格（Stage 2）

## 規格說明

### Header（頂部導航）
- 左側：顯示 App 名稱「Pu'er Sense」
- 中間：倉庫切換器（Dropdown 樣式），顯示當前位置（如「Menghai Depot」）
- 右側：用戶頭像按鈕，帶有微磨砂玻璃效果

### Main Area（主要內容）
- **Bento Grid（便當佈局）：** 兩個方形卡片並排
  - 左卡：即時數據（溫度/濕度），大號數字排版
  - 右卡：異常警報（Alerts），有警報時顯示紅色/琥珀色狀態，否則顯示「All Clear」
- **Swipe Cards（滑動卡片）：**
  - 使用 framer-motion 實現水平 snap 滾動，模擬 iOS 分頁視圖
  - 卡片 1（溫度）：SVG 曲線圖（Chart）與列表（List）切換
  - 卡片 2（濕度）：SVG 長條圖與列表切換
  - 卡片 3（裝置）：ESP32 連線狀態列表（Online/Offline）
  - 底部有分頁指示器（Pagination Dots）

### Footer（底部功能）
- 一個浮動膠囊狀按鈕或底部欄，引導至「Warehouse Management」（倉庫管理）

### 視覺風格
- 延續 Digital Wabi-Sabi：Stone-50 背景、圓角 Rounded-3xl、細微內陰影與材質疊加

---

## React/TypeScript 實作範例

```tsx
import React, { useState, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { TextureOverlay } from '../components/TextureOverlay';
import { 
  Bell, 
  ChevronDown, 
  Settings, 
  Thermometer, 
  Droplets, 
  List, 
  TrendingUp, 
  Wifi, 
  WifiOff, 
  Battery, 
  Warehouse,
  AlertTriangle,
  CheckCircle2
} from 'lucide-react';

interface DashboardViewProps {
  onLogout: () => void;
}

// Mock Data
const TEMPERATURE_DATA = [22, 23, 24, 23, 25, 26, 24];
const HUMIDITY_DATA = [60, 62, 65, 64, 68, 65, 63];
const DEVICES = [
  { id: 'ESP-01', location: 'Section A', status: 'online', battery: 85 },
  { id: 'ESP-02', location: 'Section B', status: 'online', battery: 72 },
  { id: 'ESP-03', location: 'Ceiling', status: 'offline', battery: 0 },
  { id: 'ESP-04', location: 'Floor', status: 'online', battery: 45 },
];

export default function DashboardView({ onLogout }: DashboardViewProps) {
  const [activeTab, setActiveTab] = useState(0);

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="flex flex-col h-full w-full max-w-md relative bg-stone-50 text-stone-800"
    >
      {/* Header */}
      <header className="pt-12 px-6 pb-4 flex justify-between items-center z-50 bg-stone-50/80 backdrop-blur-md sticky top-0">
        <div className="text-xs font-bold tracking-widest uppercase text-stone-400">
          Pu'er Sense
        </div>
        <button className="flex items-center gap-2 bg-stone-100 px-4 py-2 rounded-full shadow-sm active:scale-95 transition-transform">
          <span className="font-bold text-stone-700 text-sm">Menghai Depot</span>
          <ChevronDown size={14} className="text-stone-400" />
        </button>
        <button onClick={onLogout} className="w-10 h-10 rounded-full bg-stone-200 overflow-hidden border-2 border-white shadow-sm relative group">
           <img 
             src="https://api.dicebear.com/7.x/notionists/svg?seed=Felix" 
             alt="User" 
             className="w-full h-full object-cover opacity-80 group-hover:opacity-100 transition-opacity"
           />
        </button>
      </header>

      {/* Main Content */}
      <div className="flex-1 overflow-y-auto px-6 pb-24 no-scrollbar space-y-6">
        {/* Bento Grid */}
        <div className="grid grid-cols-2 gap-4 h-40">
            {/* Metric Card */}
            <div className="bg-white rounded-[32px] p-5 shadow-[0_4px_20px_-4px_rgba(0,0,0,0.05)] flex flex-col justify-between relative overflow-hidden">
                <TextureOverlay opacity={0.05} />
                <div className="flex justify-between items-start z-10">
                    <div className="flex flex-col">
                        <span className="text-3xl font-bold text-stone-800 tracking-tight">24°</span>
                        <span className="text-xs text-stone-400 font-medium uppercase mt-1">Avg Temp</span>
                    </div>
                    <Thermometer size={18} className="text-amber-600/80" />
                </div>
                <div className="flex justify-between items-end z-10">
                    <div className="flex flex-col">
                        <span className="text-3xl font-bold text-stone-800 tracking-tight">65%</span>
                        <span className="text-xs text-stone-400 font-medium uppercase mt-1">Humidity</span>
                    </div>
                    <Droplets size={18} className="text-blue-600/80" />
                </div>
            </div>
            {/* Alert Card */}
            <div className="bg-stone-800 rounded-[32px] p-5 shadow-[0_4px_20px_-4px_rgba(0,0,0,0.1)] flex flex-col justify-between relative overflow-hidden text-stone-100">
                <TextureOverlay opacity={0.1} />
                <div className="flex justify-between items-start z-10">
                    <span className="text-xs font-bold uppercase tracking-wider opacity-60">Status</span>
                    <div className="w-2 h-2 rounded-full bg-red-500 animate-pulse" />
                </div>
                <div className="z-10">
                    <div className="flex items-center gap-2 mb-1 text-red-300">
                        <AlertTriangle size={18} />
                        <span className="font-bold">Alert</span>
                    </div>
                    <p className="text-sm leading-tight text-stone-300">
                        Filter replacement required in Zone B.
                    </p>
                </div>
            </div>
        </div>

        {/* Swipeable Cards */}
        <div className="relative">
             <div className="flex items-center justify-between px-1 mb-3">
                <h3 className="font-bold text-stone-700 text-lg">Analytics</h3>
                <div className="flex gap-1.5">
                    {[0, 1, 2].map(i => (
                        <div 
                            key={i} 
                            className={`w-1.5 h-1.5 rounded-full transition-colors ${activeTab === i ? 'bg-stone-800' : 'bg-stone-300'}`} 
                        />
                    ))}
                </div>
             </div>
             {/* Horizontal Scroll Snap Container */}
             <div 
                className="flex overflow-x-auto snap-x snap-mandatory gap-4 pb-4 no-scrollbar"
                onScroll={(e) => {
                    const scrollLeft = e.currentTarget.scrollLeft;
                    const width = e.currentTarget.offsetWidth;
                    const newIndex = Math.round(scrollLeft / width);
                    if (newIndex !== activeTab) setActiveTab(newIndex);
                }}
             >
                {/* Card 1: Temperature History */}
                <ChartCard 
                    title="Temperature History" 
                    subtitle="Last 7 Days"
                    icon={Thermometer}
                    color="amber"
                    data={TEMPERATURE_DATA}
                    unit="°C"
                />
                {/* Card 2: Humidity History */}
                <ChartCard 
                    title="Humidity History" 
                    subtitle="Last 7 Days"
                    icon={Droplets}
                    color="blue"
                    data={HUMIDITY_DATA}
                    unit="%"
                    type="bar"
                />
                {/* Card 3: ESP32 Device List */}
                <DeviceListCard devices={DEVICES} />
             </div>
        </div>
      </div>

      {/* Footer */}
      <div className="absolute bottom-8 left-0 right-0 px-6 z-50 flex justify-center">
        <button className="flex items-center gap-3 bg-stone-900/90 backdrop-blur-md text-stone-50 px-6 py-4 rounded-full shadow-2xl hover:scale-105 active:scale-95 transition-all w-full max-w-[320px] justify-center group">
            <Warehouse size={20} className="text-stone-300 group-hover:text-white" />
            <span className="font-semibold text-base">Manage Warehouse</span>
        </button>
      </div>
    </motion.div>
  );
}

// --- Sub-Components ---

const ChartCard = ({ title, subtitle, icon: Icon, color, data, unit, type = 'line' }: any) => {
    const [viewMode, setViewMode] = useState<'chart' | 'list'>('chart');
    const isLine = type === 'line';

    return (
        <div className="min-w-full snap-center bg-white rounded-[32px] p-6 shadow-sm border border-stone-100 h-80 flex flex-col relative overflow-hidden">
            <TextureOverlay opacity={0.03} />
            {/* ...略，詳見原始碼... */}
        </div>
    );
};

const DeviceListCard = ({ devices }: { devices: any[] }) => {
    return (
        <div className="min-w-full snap-center bg-white rounded-[32px] p-6 shadow-sm border border-stone-100 h-80 flex flex-col relative overflow-hidden">
            <TextureOverlay opacity={0.03} />
            {/* ...略，詳見原始碼... */}
        </div>
    )
}
