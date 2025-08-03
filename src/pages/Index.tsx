import { useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useAuth } from "@/contexts/AuthContext";
import { UserMenu } from "@/components/UserMenu";
import { 
  Database, 
  Upload, 
  BarChart3, 
  Settings, 
  Coffee,
  Activity,
  FileText,
  AlertTriangle
} from "lucide-react";

import { DataFlowDashboard } from "@/components/DataFlowDashboard";
import { FileUploadZone } from "@/components/FileUploadZone";
import { MachineAnalytics } from "@/components/MachineAnalytics";

const Index = () => {
  const [activeTab, setActiveTab] = useState("dashboard");
  const { profile, hasRole } = useAuth();

  return (
    <div className="min-h-screen bg-background">
      {/* Navigation Header */}
      <div className="border-b border-border">
        <div className="container mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-6">
              <div className="flex items-center space-x-3">
                <div className="p-2 rounded-lg gradient-primary">
                  <Database className="h-6 w-6 text-primary-foreground" />
                </div>
                <div>
                  <h1 className="text-2xl font-bold text-glow">DataFlow Analytics</h1>
                  <p className="text-sm text-muted-foreground">
                    Управление данными торговых автоматов
                  </p>
                </div>
              </div>
            </div>
            
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <div className="status-indicator bg-success" />
                <span className="text-sm font-medium">Система активна</span>
              </div>
              
              <Badge variant="outline" className="text-primary border-primary">
                <Activity className="w-3 h-3 mr-1" />
                87 автоматов
              </Badge>
              
              <Badge variant="outline" className="text-warning border-warning">
                <AlertTriangle className="w-3 h-3 mr-1" />
                12 проблем
              </Badge>
              
              <UserMenu />
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="container mx-auto px-6 py-6">
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-4 lg:w-fit lg:grid-cols-4 mb-8">
            <TabsTrigger 
              value="dashboard" 
              className="flex items-center space-x-2 data-[state=active]:bg-primary data-[state=active]:text-primary-foreground"
            >
              <BarChart3 className="h-4 w-4" />
              <span>Дашборд</span>
            </TabsTrigger>
            
            {hasRole('operator') && (
              <TabsTrigger 
                value="upload"
                className="flex items-center space-x-2 data-[state=active]:bg-primary data-[state=active]:text-primary-foreground"
              >
                <Upload className="h-4 w-4" />
                <span>Загрузка</span>
              </TabsTrigger>
            )}
            
            <TabsTrigger 
              value="analytics"
              className="flex items-center space-x-2 data-[state=active]:bg-primary data-[state=active]:text-primary-foreground"
            >
              <Coffee className="h-4 w-4" />
              <span>Автоматы</span>
            </TabsTrigger>
            
            {hasRole('operator') && (
              <TabsTrigger 
                value="reports"
                className="flex items-center space-x-2 data-[state=active]:bg-primary data-[state=active]:text-primary-foreground"
              >
                <FileText className="h-4 w-4" />
                <span>Отчеты</span>
              </TabsTrigger>
            )}
          </TabsList>

          <TabsContent value="dashboard" className="space-y-6">
            <DataFlowDashboard />
          </TabsContent>

          {hasRole('operator') && (
            <TabsContent value="upload" className="space-y-6">
              <div className="mb-6">
                <h2 className="text-3xl font-bold mb-2">Загрузка файлов данных</h2>
                <p className="text-muted-foreground">
                  Загрузите файлы Excel и CSV для анализа данных торговых автоматов
                </p>
              </div>
              <FileUploadZone />
            </TabsContent>
          )}

          <TabsContent value="analytics" className="space-y-6">
            <div className="mb-6">
              <h2 className="text-3xl font-bold mb-2">Аналитика автоматов</h2>
              <p className="text-muted-foreground">
                Детальная статистика работы каждого торгового автомата
              </p>
            </div>
            <MachineAnalytics />
          </TabsContent>

          {hasRole('operator') && (
            <TabsContent value="reports" className="space-y-6">
              <div className="mb-6">
                <h2 className="text-3xl font-bold mb-2">Отчеты и экспорт</h2>
                <p className="text-muted-foreground">
                  Создание и экспорт аналитических отчетов
                </p>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {[
                  {
                    title: "Сводный отчет",
                    description: "Общая статистика по всем автоматам",
                    icon: <BarChart3 className="h-8 w-8 text-primary" />,
                    color: "gradient-primary"
                  },
                  {
                    title: "Финансовый отчет",
                    description: "Детализация доходов и расходов",
                    icon: <Database className="h-8 w-8 text-success" />,
                    color: "gradient-secondary"
                  },
                  {
                    title: "Отчет по проблемам",
                    description: "Анализ ошибок и конфликтов данных",
                    icon: <AlertTriangle className="h-8 w-8 text-warning" />,
                    color: "gradient-accent"
                  },
                  {
                    title: "Качество данных",
                    description: "Метрики качества и целостности",
                    icon: <Activity className="h-8 w-8 text-accent" />,
                    color: "gradient-primary"
                  },
                  {
                    title: "Производительность",
                    description: "Скорость обработки и время отклика",
                    icon: <Coffee className="h-8 w-8 text-secondary" />,
                    color: "gradient-secondary"
                  },
                  {
                    title: "Пользовательский отчет",
                    description: "Настраиваемый отчет по выбранным метрикам",
                    icon: <Settings className="h-8 w-8 text-muted-foreground" />,
                    color: "bg-muted"
                  }
                ].map((report, index) => (
                  <Card key={index} className="analytics-card cursor-pointer group">
                    <CardContent className="p-6">
                      <div className={`w-16 h-16 rounded-lg ${report.color} flex items-center justify-center mb-4 group-hover:scale-110 transition-transform`}>
                        {report.icon}
                      </div>
                      <h3 className="text-lg font-semibold mb-2">{report.title}</h3>
                      <p className="text-muted-foreground text-sm mb-4">{report.description}</p>
                      <Button variant="outline" className="w-full">
                        Создать отчет
                      </Button>
                    </CardContent>
                  </Card>
                ))}
              </div>
            </TabsContent>
          )}
        </Tabs>
      </div>
    </div>
  );
};

export default Index;
