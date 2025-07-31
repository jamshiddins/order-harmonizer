import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Badge } from "@/components/ui/badge";
import { OrdersDialog } from "./OrdersDialog";
import { useState } from "react";
import { 
  Database, 
  Upload, 
  AlertTriangle, 
  CheckCircle, 
  XCircle, 
  Clock, 
  TrendingUp,
  FileText,
  Activity
} from "lucide-react";

interface MetricCardProps {
  title: string;
  value: string;
  change?: string;
  trend?: "up" | "down" | "stable";
  icon: React.ReactNode;
  className?: string;
  onClick?: () => void;
}

const MetricCard = ({ title, value, change, trend, icon, className, onClick }: MetricCardProps) => (
  <Card className={`analytics-card ${className} ${onClick ? 'cursor-pointer hover:shadow-lg transition-shadow' : ''}`} onClick={onClick}>
    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
      <CardTitle className="text-sm font-medium text-muted-foreground">{title}</CardTitle>
      <div className="text-primary">{icon}</div>
    </CardHeader>
    <CardContent>
      <div className={`metric-number ${onClick ? 'text-primary hover:text-primary-dark' : ''}`}>{value}</div>
      {change && (
        <p className={`text-xs ${
          trend === 'up' ? 'text-success' : 
          trend === 'down' ? 'text-destructive' : 
          'text-muted-foreground'
        }`}>
          {change}
        </p>
      )}
    </CardContent>
  </Card>
);

interface StatusIndicatorProps {
  status: "success" | "warning" | "error" | "processing";
  label: string;
  count?: number;
}

const StatusIndicator = ({ status, label, count }: StatusIndicatorProps) => {
  const statusConfig = {
    success: { color: "bg-success", textColor: "text-success" },
    warning: { color: "bg-warning", textColor: "text-warning" },
    error: { color: "bg-destructive", textColor: "text-destructive" },
    processing: { color: "bg-primary", textColor: "text-primary" }
  };

  const config = statusConfig[status];

  return (
    <div className="flex items-center space-x-3 cursor-pointer hover:bg-accent/50 p-2 rounded-lg transition-colors">
      <div className={`status-indicator ${config.color}`} />
      <span className="text-sm font-medium">{label}</span>
      {count !== undefined && (
        <Badge variant="outline" className={`${config.textColor} hover:bg-current hover:text-background`}>
          {count}
        </Badge>
      )}
    </div>
  );
};

export const DataFlowDashboard = () => {
  const [ordersDialogOpen, setOrdersDialogOpen] = useState(false);
  const [dialogTitle, setDialogTitle] = useState('');

  const handleMetricClick = (title: string) => {
    setDialogTitle(title);
    setOrdersDialogOpen(true);
  };

  return (
    <div className="min-h-screen bg-background p-6">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center space-x-4 mb-4">
          <div className="p-3 rounded-lg bg-primary/10">
            <Database className="h-8 w-8 text-primary" />
          </div>
          <div>
            <h1 className="text-4xl font-bold gradient-primary bg-clip-text text-transparent">
              DataFlow Analytics
            </h1>
            <p className="text-muted-foreground">
              Управление данными торговых автоматов
            </p>
          </div>
        </div>
        
        <div className="flex flex-wrap gap-4">
          <Button className="bg-primary hover:bg-primary-dark">
            <Upload className="mr-2 h-4 w-4" />
            Загрузить файлы
          </Button>
          <Button variant="outline">
            <Activity className="mr-2 h-4 w-4" />
            Мониторинг
          </Button>
          <Button variant="outline">
            <FileText className="mr-2 h-4 w-4" />
            Отчеты
          </Button>
        </div>
      </div>

      {/* Metrics Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <MetricCard
          title="Всего заказов"
          value="12,485"
          change="+12.5% за месяц"
          trend="up"
          icon={<TrendingUp className="h-4 w-4" />}
          onClick={() => handleMetricClick('Все заказы (12,485)')}
        />
        <MetricCard
          title="Обработанные файлы"
          value="156"
          change="+3 сегодня"
          trend="up"
          icon={<FileText className="h-4 w-4" />}
          onClick={() => handleMetricClick('Обработанные файлы (156)')}
        />
        <MetricCard
          title="Качество данных"
          value="94.2%"
          change="+2.1% улучшение"
          trend="up"
          icon={<CheckCircle className="h-4 w-4" />}
          onClick={() => handleMetricClick('Проверенные заказы (94.2%)')}
        />
        <MetricCard
          title="Активные автоматы"
          value="87"
          change="2 офлайн"
          trend="stable"
          icon={<Activity className="h-4 w-4" />}
          onClick={() => handleMetricClick('Заказы активных автоматов (87)')}
        />
      </div>

      {/* Status Overview & Data Processing */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        {/* Data Processing Status */}
        <Card className="analytics-card">
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <Clock className="h-5 w-5 text-primary" />
              <span>Статус обработки данных</span>
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-3">
              <div onClick={() => handleMetricClick('Hardware Orders (2,847)')}>
                <StatusIndicator status="success" label="Hardware Orders (HW.xlsx)" count={2847} />
              </div>
              <div onClick={() => handleMetricClick('Sales Reports (2,654)')}>
                <StatusIndicator status="success" label="Sales Reports (report.xlsx)" count={2654} />
              </div>
              <div onClick={() => handleMetricClick('Fiscal Receipts (1,923)')}>
                <StatusIndicator status="warning" label="Fiscal Receipts" count={1923} />
              </div>
              <div onClick={() => handleMetricClick('Payme Payments (856)')}>
                <StatusIndicator status="processing" label="Payme Payments" count={856} />
              </div>
              <div onClick={() => handleMetricClick('Click Payments (45)')}>
                <StatusIndicator status="error" label="Click Payments" count={45} />
              </div>
              <div onClick={() => handleMetricClick('Uzum Payments (234)')}>
                <StatusIndicator status="success" label="Uzum Payments" count={234} />
              </div>
            </div>
            
            <div className="pt-4 border-t border-border">
              <div className="flex justify-between text-sm mb-2">
                <span>Общий прогресс</span>
                <span className="text-primary font-medium">87%</span>
              </div>
              <Progress value={87} className="h-2" />
            </div>
          </CardContent>
        </Card>

        {/* Issues Dashboard */}
        <Card className="analytics-card">
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <AlertTriangle className="h-5 w-5 text-warning" />
              <span>Обнаруженные проблемы</span>
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-3">
              <div 
                className="flex items-center justify-between p-3 rounded-lg bg-destructive/10 border border-destructive/20 cursor-pointer hover:bg-destructive/20 transition-colors"
                onClick={() => handleMetricClick('Временные заказы (23)')}
              >
                <div className="flex items-center space-x-3">
                  <XCircle className="h-4 w-4 text-destructive" />
                  <span className="text-sm font-medium">Временные заказы</span>
                </div>
                <Badge variant="destructive">23</Badge>
              </div>
              
              <div 
                className="flex items-center justify-between p-3 rounded-lg bg-warning/10 border border-warning/20 cursor-pointer hover:bg-warning/20 transition-colors"
                onClick={() => handleMetricClick('Конфликты данных (7)')}
              >
                <div className="flex items-center space-x-3">
                  <AlertTriangle className="h-4 w-4 text-warning" />
                  <span className="text-sm font-medium">Конфликты данных</span>
                </div>
                <Badge className="bg-warning text-warning-foreground">7</Badge>
              </div>
              
              <div 
                className="flex items-center justify-between p-3 rounded-lg bg-warning/10 border border-warning/20 cursor-pointer hover:bg-warning/20 transition-colors"
                onClick={() => handleMetricClick('Расхождения сумм (12)')}
              >
                <div className="flex items-center space-x-3">
                  <AlertTriangle className="h-4 w-4 text-warning" />
                  <span className="text-sm font-medium">Расхождения сумм</span>
                </div>
                <Badge className="bg-warning text-warning-foreground">12</Badge>
              </div>
              
              <div 
                className="flex items-center justify-between p-3 rounded-lg bg-success/10 border border-success/20 cursor-pointer hover:bg-success/20 transition-colors"
                onClick={() => handleMetricClick('Успешно сопоставленные заказы (8,432)')}
              >
                <div className="flex items-center space-x-3">
                  <CheckCircle className="h-4 w-4 text-success" />
                  <span className="text-sm font-medium">Успешно сопоставлено</span>
                </div>
                <Badge className="bg-success text-success-foreground">8,432</Badge>
              </div>
            </div>
            
            <Button variant="outline" className="w-full">
              Подробный анализ проблем
            </Button>
          </CardContent>
        </Card>
      </div>

      {/* Data Flow Visualization */}
      <Card className="analytics-card">
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Database className="h-5 w-5 text-primary" />
            <span>Поток данных</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-6 gap-4">
            {[
              { name: "Hardware Orders", status: "active", count: "2,847" },
              { name: "Sales Reports", status: "active", count: "2,654" },
              { name: "Fiscal Receipts", status: "warning", count: "1,923" },
              { name: "Payme", status: "processing", count: "856" },
              { name: "Click", status: "error", count: "45" },
              { name: "Uzum", status: "active", count: "234" }
            ].map((source, index) => (
              <div key={source.name} className="text-center data-flow-animation">
                <div 
                  className={`w-16 h-16 mx-auto rounded-full flex items-center justify-center mb-3 ${
                    source.status === 'active' ? 'bg-success/20 border-2 border-success' :
                    source.status === 'warning' ? 'bg-warning/20 border-2 border-warning' :
                    source.status === 'error' ? 'bg-destructive/20 border-2 border-destructive' :
                    'bg-primary/20 border-2 border-primary animate-pulse'
                  }`}
                  style={{ animationDelay: `${index * 0.2}s` }}
                >
                  <Database className="h-6 w-6" />
                </div>
                <h3 className="text-sm font-medium mb-1">{source.name}</h3>
                <p className="text-xs text-muted-foreground">{source.count} записей</p>
              </div>
            ))}
          </div>
          
          <div className="mt-8 text-center">
            <div 
              className="inline-flex items-center space-x-2 px-4 py-2 rounded-full bg-primary/10 border border-primary/20 cursor-pointer hover:bg-primary/20 transition-colors"
              onClick={() => handleMetricClick('Unified Orders Database (8,432)')}
            >
              <div className="w-3 h-3 rounded-full bg-primary animate-pulse" />
              <span className="text-sm font-medium text-primary">
                Unified Orders Database - 8,432 активных записи
              </span>
            </div>
          </div>
        </CardContent>
      </Card>

      <OrdersDialog
        open={ordersDialogOpen}
        onOpenChange={setOrdersDialogOpen}
        title={dialogTitle}
        orders={[]}
      />
    </div>
  );
};