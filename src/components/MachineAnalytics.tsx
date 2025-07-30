import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { 
  Coffee, 
  TrendingUp, 
  DollarSign, 
  AlertTriangle,
  CheckCircle,
  Clock,
  MapPin,
  BarChart3
} from "lucide-react";

interface MachineData {
  id: string;
  code: string;
  address: string;
  totalOrders: number;
  successfulOrders: number;
  totalRevenue: number;
  avgOrderValue: number;
  successRate: number;
  refundRate: number;
  avgProcessingTime: number;
  popularProduct: string;
  status: 'online' | 'offline' | 'maintenance';
  lastUpdate: string;
  issues: number;
}

const machineData: MachineData[] = [
  {
    id: "1",
    code: "a7ca181f0000",
    address: "кудрат первушка",
    totalOrders: 2847,
    successfulOrders: 2654,
    totalRevenue: 42850000,
    avgOrderValue: 15000,
    successRate: 93.2,
    refundRate: 1.8,
    avgProcessingTime: 45,
    popularProduct: "Hot Chocolate",
    status: 'online',
    lastUpdate: "2 мин назад",
    issues: 0
  },
  {
    id: "2",
    code: "b8db292g1111",
    address: "ТРЦ Compass",
    totalOrders: 1923,
    successfulOrders: 1854,
    totalRevenue: 28845000,
    avgOrderValue: 15000,
    successRate: 96.4,
    refundRate: 0.9,
    avgProcessingTime: 38,
    popularProduct: "Cappuccino",
    status: 'online',
    lastUpdate: "1 мин назад",
    issues: 2
  },
  {
    id: "3",
    code: "c9ec3a3h2222",
    address: "БЦ City Palace",
    totalOrders: 856,
    successfulOrders: 734,
    totalRevenue: 11040000,
    avgOrderValue: 12900,
    successRate: 85.7,
    refundRate: 4.2,
    avgProcessingTime: 67,
    popularProduct: "Espresso",
    status: 'maintenance',
    lastUpdate: "2 часа назад",
    issues: 5
  },
  {
    id: "4",
    code: "d0fd4b4i3333",
    address: "Метро Алайский базар",
    totalOrders: 3421,
    successfulOrders: 3289,
    totalRevenue: 51315000,
    avgOrderValue: 15000,
    successRate: 96.1,
    refundRate: 1.1,
    avgProcessingTime: 41,
    popularProduct: "Americano",
    status: 'online',
    lastUpdate: "30 сек назад",
    issues: 1
  },
  {
    id: "5",
    code: "e1ge5c5j4444",
    address: "Аэропорт Ташкент",
    totalOrders: 0,
    successfulOrders: 0,
    totalRevenue: 0,
    avgOrderValue: 0,
    successRate: 0,
    refundRate: 0,
    avgProcessingTime: 0,
    popularProduct: "-",
    status: 'offline',
    lastUpdate: "3 дня назад",
    issues: 8
  }
];

const formatCurrency = (amount: number): string => {
  return new Intl.NumberFormat('uz-UZ', {
    style: 'currency',
    currency: 'UZS',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(amount);
};

const getStatusConfig = (status: MachineData['status']) => {
  switch (status) {
    case 'online':
      return { color: 'bg-success', textColor: 'text-success', label: 'Онлайн' };
    case 'offline':
      return { color: 'bg-destructive', textColor: 'text-destructive', label: 'Офлайн' };
    case 'maintenance':
      return { color: 'bg-warning', textColor: 'text-warning', label: 'Обслуживание' };
    default:
      return { color: 'bg-muted', textColor: 'text-muted-foreground', label: 'Неизвестно' };
  }
};

export const MachineAnalytics = () => {
  const totalMachines = machineData.length;
  const onlineMachines = machineData.filter(m => m.status === 'online').length;
  const totalRevenue = machineData.reduce((sum, m) => sum + m.totalRevenue, 0);
  const totalOrders = machineData.reduce((sum, m) => sum + m.totalOrders, 0);
  const avgSuccessRate = machineData.reduce((sum, m) => sum + m.successRate, 0) / totalMachines;

  return (
    <div className="space-y-6">
      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card className="analytics-card">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Активные автоматы
            </CardTitle>
            <Coffee className="h-4 w-4 text-primary" />
          </CardHeader>
          <CardContent>
            <div className="metric-number">{onlineMachines}/{totalMachines}</div>
            <p className="text-xs text-success">
              {Math.round((onlineMachines / totalMachines) * 100)}% в сети
            </p>
          </CardContent>
        </Card>

        <Card className="analytics-card">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Общая выручка
            </CardTitle>
            <DollarSign className="h-4 w-4 text-success" />
          </CardHeader>
          <CardContent>
            <div className="metric-number">{formatCurrency(totalRevenue).slice(0, -4)}М</div>
            <p className="text-xs text-success">+12.5% за месяц</p>
          </CardContent>
        </Card>

        <Card className="analytics-card">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Всего заказов
            </CardTitle>
            <BarChart3 className="h-4 w-4 text-secondary" />
          </CardHeader>
          <CardContent>
            <div className="metric-number">{totalOrders.toLocaleString()}</div>
            <p className="text-xs text-success">+8.2% за неделю</p>
          </CardContent>
        </Card>

        <Card className="analytics-card">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Средний успех
            </CardTitle>
            <TrendingUp className="h-4 w-4 text-accent" />
          </CardHeader>
          <CardContent>
            <div className="metric-number">{avgSuccessRate.toFixed(1)}%</div>
            <p className="text-xs text-success">+1.3% улучшение</p>
          </CardContent>
        </Card>
      </div>

      {/* Machine Details */}
      <Card className="analytics-card">
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Coffee className="h-5 w-5 text-primary" />
            <span>Детальная аналитика автоматов</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-6">
            {machineData.map((machine) => {
              const statusConfig = getStatusConfig(machine.status);
              
              return (
                <div key={machine.id} className="border border-border rounded-lg p-6">
                  {/* Machine Header */}
                  <div className="flex items-center justify-between mb-4">
                    <div className="flex items-center space-x-4">
                      <div className={`status-indicator ${statusConfig.color}`} />
                      <div>
                        <h3 className="font-semibold text-lg">{machine.code}</h3>
                        <div className="flex items-center space-x-2 text-muted-foreground">
                          <MapPin className="h-4 w-4" />
                          <span className="text-sm">{machine.address}</span>
                        </div>
                      </div>
                    </div>
                    
                    <div className="flex items-center space-x-3">
                      <Badge 
                        className={`${statusConfig.textColor} border-current`}
                        variant="outline"
                      >
                        {statusConfig.label}
                      </Badge>
                      
                      {machine.issues > 0 && (
                        <Badge variant="destructive" className="flex items-center space-x-1">
                          <AlertTriangle className="h-3 w-3" />
                          <span>{machine.issues}</span>
                        </Badge>
                      )}
                      
                      <span className="text-xs text-muted-foreground">
                        {machine.lastUpdate}
                      </span>
                    </div>
                  </div>

                  {/* Metrics Grid */}
                  <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4 mb-4">
                    <div className="text-center p-3 rounded-lg bg-primary/10">
                      <p className="text-2xl font-bold text-primary">
                        {machine.totalOrders.toLocaleString()}
                      </p>
                      <p className="text-xs text-muted-foreground">Заказов</p>
                    </div>
                    
                    <div className="text-center p-3 rounded-lg bg-success/10">
                      <p className="text-2xl font-bold text-success">
                        {formatCurrency(machine.totalRevenue).slice(0, -4)}К
                      </p>
                      <p className="text-xs text-muted-foreground">Выручка</p>
                    </div>
                    
                    <div className="text-center p-3 rounded-lg bg-secondary/10">
                      <p className="text-2xl font-bold text-secondary">
                        {machine.successRate.toFixed(1)}%
                      </p>
                      <p className="text-xs text-muted-foreground">Успешность</p>
                    </div>
                    
                    <div className="text-center p-3 rounded-lg bg-accent/10">
                      <p className="text-2xl font-bold text-accent">
                        {machine.avgProcessingTime}с
                      </p>
                      <p className="text-xs text-muted-foreground">Время</p>
                    </div>
                    
                    <div className="text-center p-3 rounded-lg bg-warning/10">
                      <p className="text-2xl font-bold text-warning">
                        {machine.refundRate.toFixed(1)}%
                      </p>
                      <p className="text-xs text-muted-foreground">Возвраты</p>
                    </div>
                    
                    <div className="text-center p-3 rounded-lg bg-muted/50">
                      <p className="text-sm font-bold text-foreground">
                        {machine.popularProduct}
                      </p>
                      <p className="text-xs text-muted-foreground">Популярное</p>
                    </div>
                  </div>

                  {/* Progress Bars */}
                  <div className="space-y-3">
                    <div>
                      <div className="flex justify-between text-sm mb-1">
                        <span>Успешность доставки</span>
                        <span className="text-success font-medium">
                          {machine.successRate.toFixed(1)}%
                        </span>
                      </div>
                      <Progress value={machine.successRate} className="h-2" />
                    </div>
                    
                    {machine.status !== 'offline' && (
                      <div>
                        <div className="flex justify-between text-sm mb-1">
                          <span>Эффективность работы</span>
                          <span className="text-primary font-medium">
                            {(100 - machine.refundRate).toFixed(1)}%
                          </span>
                        </div>
                        <Progress value={100 - machine.refundRate} className="h-2" />
                      </div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>
    </div>
  );
};