import React from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";
import { ScrollArea } from "@/components/ui/scroll-area";
import { formatDistanceToNow } from 'date-fns';
import { ru } from 'date-fns/locale';
import { 
  CheckCircle, 
  XCircle, 
  Clock, 
  CreditCard,
  Coffee,
  MapPin,
  Calendar
} from "lucide-react";

interface Order {
  id: string;
  machineCode: string;
  machineAddress: string;
  product: string;
  amount: number;
  status: 'success' | 'failed' | 'refunded' | 'processing';
  paymentMethod: 'payme' | 'click' | 'uzum' | 'cash';
  timestamp: Date;
  processingTime?: number;
  errorMessage?: string;
}

interface OrdersDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title: string;
  orders: Order[];
}

// Генерируем примерные заказы для демонстрации
const generateSampleOrders = (count: number): Order[] => {
  const products = ['Cappuccino', 'Americano', 'Espresso', 'Hot Chocolate', 'Latte', 'Tea'];
  const machines = [
    { code: 'a7ca181f0000', address: 'кудрат первушка' },
    { code: 'b8db292g1111', address: 'ТРЦ Compass' },
    { code: 'c9ec3a3h2222', address: 'БЦ City Palace' },
    { code: 'd0fd4b4i3333', address: 'Метро Алайский базар' },
  ];
  const statuses: Order['status'][] = ['success', 'failed', 'refunded', 'processing'];
  const paymentMethods: Order['paymentMethod'][] = ['payme', 'click', 'uzum', 'cash'];

  return Array.from({ length: count }, (_, i) => {
    const machine = machines[Math.floor(Math.random() * machines.length)];
    const status = statuses[Math.floor(Math.random() * statuses.length)];
    
    return {
      id: `order_${i + 1}`,
      machineCode: machine.code,
      machineAddress: machine.address,
      product: products[Math.floor(Math.random() * products.length)],
      amount: Math.floor(Math.random() * 25000) + 10000,
      status,
      paymentMethod: paymentMethods[Math.floor(Math.random() * paymentMethods.length)],
      timestamp: new Date(Date.now() - Math.floor(Math.random() * 7 * 24 * 60 * 60 * 1000)),
      processingTime: status === 'success' ? Math.floor(Math.random() * 60) + 30 : undefined,
      errorMessage: status === 'failed' ? 'Недостаточно средств на карте' : undefined
    };
  });
};

const formatCurrency = (amount: number): string => {
  return new Intl.NumberFormat('uz-UZ', {
    style: 'currency',
    currency: 'UZS',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(amount);
};

const getStatusConfig = (status: Order['status']) => {
  switch (status) {
    case 'success':
      return { 
        color: 'bg-success', 
        textColor: 'text-success', 
        label: 'Успешно', 
        icon: CheckCircle 
      };
    case 'failed':
      return { 
        color: 'bg-destructive', 
        textColor: 'text-destructive', 
        label: 'Ошибка', 
        icon: XCircle 
      };
    case 'refunded':
      return { 
        color: 'bg-warning', 
        textColor: 'text-warning', 
        label: 'Возврат', 
        icon: Clock 
      };
    case 'processing':
      return { 
        color: 'bg-primary', 
        textColor: 'text-primary', 
        label: 'Обработка', 
        icon: Clock 
      };
    default:
      return { 
        color: 'bg-muted', 
        textColor: 'text-muted-foreground', 
        label: 'Неизвестно', 
        icon: Clock 
      };
  }
};

const getPaymentMethodLabel = (method: Order['paymentMethod']) => {
  switch (method) {
    case 'payme': return 'Payme';
    case 'click': return 'Click';
    case 'uzum': return 'Uzum';
    case 'cash': return 'Наличные';
    default: return method;
  }
};

export const OrdersDialog: React.FC<OrdersDialogProps> = ({ 
  open, 
  onOpenChange, 
  title, 
  orders: providedOrders 
}) => {
  // Если заказы не предоставлены, генерируем примерные
  const orders = providedOrders.length > 0 ? providedOrders : generateSampleOrders(50);

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-4xl h-[80vh]">
        <DialogHeader>
          <DialogTitle className="flex items-center space-x-2">
            <Coffee className="h-5 w-5 text-primary" />
            <span>{title}</span>
            <Badge variant="outline">{orders.length} заказов</Badge>
          </DialogTitle>
        </DialogHeader>
        
        <ScrollArea className="flex-1 pr-4">
          <div className="space-y-3">
            {orders.map((order) => {
              const statusConfig = getStatusConfig(order.status);
              const StatusIcon = statusConfig.icon;
              
              return (
                <Card key={order.id} className="hover:shadow-md transition-shadow">
                  <CardContent className="p-4">
                    <div className="flex items-center justify-between mb-3">
                      <div className="flex items-center space-x-3">
                        <div className={`status-indicator ${statusConfig.color}`} />
                        <div>
                          <div className="font-medium">{order.product}</div>
                          <div className="text-sm text-muted-foreground">
                            ID: {order.id}
                          </div>
                        </div>
                      </div>
                      
                      <div className="text-right">
                        <div className="font-bold text-lg">
                          {formatCurrency(order.amount)}
                        </div>
                        <Badge 
                          variant="outline"
                          className={`${statusConfig.textColor} border-current`}
                        >
                          <StatusIcon className="h-3 w-3 mr-1" />
                          {statusConfig.label}
                        </Badge>
                      </div>
                    </div>
                    
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                      <div className="flex items-center space-x-2">
                        <MapPin className="h-4 w-4 text-muted-foreground" />
                        <div>
                          <div className="font-medium">{order.machineCode}</div>
                          <div className="text-muted-foreground">{order.machineAddress}</div>
                        </div>
                      </div>
                      
                      <div className="flex items-center space-x-2">
                        <CreditCard className="h-4 w-4 text-muted-foreground" />
                        <div>
                          <div className="font-medium">{getPaymentMethodLabel(order.paymentMethod)}</div>
                          {order.processingTime && (
                            <div className="text-muted-foreground">
                              {order.processingTime}с обработки
                            </div>
                          )}
                        </div>
                      </div>
                      
                      <div className="flex items-center space-x-2">
                        <Calendar className="h-4 w-4 text-muted-foreground" />
                        <div>
                          <div className="font-medium">
                            {formatDistanceToNow(order.timestamp, { 
                              addSuffix: true, 
                              locale: ru 
                            })}
                          </div>
                          <div className="text-muted-foreground">
                            {order.timestamp.toLocaleDateString('ru-RU')}
                          </div>
                        </div>
                      </div>
                    </div>
                    
                    {order.errorMessage && (
                      <div className="mt-3 p-2 rounded bg-destructive/10 border border-destructive/20">
                        <div className="text-sm text-destructive font-medium">
                          {order.errorMessage}
                        </div>
                      </div>
                    )}
                  </CardContent>
                </Card>
              );
            })}
          </div>
        </ScrollArea>
      </DialogContent>
    </Dialog>
  );
};