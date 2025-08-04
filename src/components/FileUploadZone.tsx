import { useState, useCallback } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Badge } from "@/components/ui/badge";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { useToast } from "@/hooks/use-toast";
import { useAuth } from "@/contexts/AuthContext";
import { supabase } from "@/integrations/supabase/client";
import { 
  Upload, 
  FileText, 
  CheckCircle, 
  AlertTriangle, 
  X,
  Database,
  Clock
} from "lucide-react";

interface FileInfo {
  id: string;
  name: string;
  size: number;
  type: 'hardware' | 'sales' | 'fiscal' | 'payme' | 'click' | 'uzum' | 'unknown';
  status: 'pending' | 'processing' | 'completed' | 'error';
  progress: number;
  errorMessage?: string;
  recordsProcessed?: number;
  recordsMatched?: number;
  duplicatesFound?: number;
}

const fileTypeConfig = {
  hardware: { 
    label: "Hardware Orders", 
    color: "bg-primary", 
    description: "Основной источник данных (HW.xlsx)",
    priority: 1 
  },
  sales: { 
    label: "Sales Reports", 
    color: "bg-secondary", 
    description: "VendHub отчеты (report.xlsx)",
    priority: 2 
  },
  fiscal: { 
    label: "Fiscal Receipts", 
    color: "bg-accent", 
    description: "Фискальные чеки (fiscal_bills.xlsx)",
    priority: 3 
  },
  payme: { 
    label: "Payme Payments", 
    color: "bg-success", 
    description: "Платежи через Payme",
    priority: 4 
  },
  click: { 
    label: "Click Payments", 
    color: "bg-warning", 
    description: "Платежи через Click",
    priority: 5 
  },
  uzum: { 
    label: "Uzum Payments", 
    color: "bg-destructive", 
    description: "Платежи через Uzum/Liuzon",
    priority: 6 
  },
  unknown: { 
    label: "Unknown Type", 
    color: "bg-muted", 
    description: "Неопределенный тип файла",
    priority: 99 
  }
};

const detectFileType = (filename: string): FileInfo['type'] => {
  const name = filename.toLowerCase();
  if (name.includes('hw') || name.includes('hardware')) return 'hardware';
  if (name.includes('report') || name.includes('sales')) return 'sales';
  if (name.includes('fiscal') || name.includes('bill')) return 'fiscal';
  if (name.includes('payme')) return 'payme';
  if (name.includes('click')) return 'click';
  if (name.includes('uzum') || name.includes('liuzon')) return 'uzum';
  return 'unknown';
};

const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

export const FileUploadZone = () => {
  const [files, setFiles] = useState<FileInfo[]>([]);
  const [dragActive, setDragActive] = useState(false);
  const { toast } = useToast();
  const { user } = useAuth();

  const calculateFileHash = async (file: File): Promise<string> => {
    const buffer = await file.arrayBuffer();
    const hashBuffer = await crypto.subtle.digest('SHA-256', buffer);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  };

  const uploadFile = async (fileInfo: FileInfo, file: File) => {
    if (!user) {
      toast({
        title: "Ошибка",
        description: "Необходимо войти в систему для загрузки файлов",
        variant: "destructive",
      });
      return;
    }

    try {
      // Обновляем статус на обработку
      setFiles(prev => prev.map(f => 
        f.id === fileInfo.id ? { ...f, status: 'processing', progress: 10 } : f
      ));

      const contentHash = await calculateFileHash(file);
      
      // Проверяем дубликаты
      const { data: duplicates } = await supabase
        .from('files')
        .select('id, original_name')
        .eq('content_hash', contentHash)
        .eq('file_type', fileInfo.type);

      if (duplicates && duplicates.length > 0) {
        throw new Error(`Файл уже загружен: ${duplicates[0].original_name}`);
      }

      // Обновляем прогресс
      setFiles(prev => prev.map(f => 
        f.id === fileInfo.id ? { ...f, progress: 50 } : f
      ));

      // Создаем запись в базе данных
      const { data: fileRecord, error: dbError } = await supabase
        .from('files')
        .insert({
          filename: `${Date.now()}_${file.name}`,
          original_name: file.name,
          file_type: fileInfo.type,
          content_hash: contentHash,
          file_size: file.size,
          uploaded_by: user.id,
          processing_status: 'pending'
        })
        .select()
        .single();

      if (dbError) throw dbError;

      // Завершаем загрузку
      setFiles(prev => prev.map(f => 
        f.id === fileInfo.id ? { 
          ...f, 
          status: 'completed', 
          progress: 100,
          recordsProcessed: 0, // Будет обновлено после обработки
          recordsMatched: 0,
          duplicatesFound: 0
        } : f
      ));

      toast({
        title: "Файл загружен",
        description: `${file.name} успешно загружен и готов к обработке`,
      });

    } catch (error) {
      console.error('Upload error:', error);
      setFiles(prev => prev.map(f => 
        f.id === fileInfo.id ? { 
          ...f, 
          status: 'error', 
          errorMessage: error instanceof Error ? error.message : 'Ошибка загрузки'
        } : f
      ));

      toast({
        title: "Ошибка загрузки",
        description: error instanceof Error ? error.message : 'Произошла ошибка при загрузке файла',
        variant: "destructive",
      });
    }
  };

  const handleDrop = useCallback((e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);

    const droppedFiles = Array.from(e.dataTransfer.files);
    processFiles(droppedFiles);
  }, []);

  const handleChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    e.preventDefault();
    if (e.target.files && e.target.files[0]) {
      const selectedFiles = Array.from(e.target.files);
      processFiles(selectedFiles);
    }
  }, []);

  const processFiles = (newFiles: File[]) => {
    const fileInfos: FileInfo[] = newFiles.map(file => ({
      id: Math.random().toString(36).substr(2, 9),
      name: file.name,
      size: file.size,
      type: detectFileType(file.name),
      status: 'pending',
      progress: 0
    }));

    setFiles(prev => [...prev, ...fileInfos]);

    // Запускаем загрузку файлов
    fileInfos.forEach((fileInfo, index) => {
      const originalFile = newFiles[index];
      setTimeout(() => uploadFile(fileInfo, originalFile), Math.random() * 1000);
    });
  };

  const handleDrag = useCallback((e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === "dragenter" || e.type === "dragover") {
      setDragActive(true);
    } else if (e.type === "dragleave") {
      setDragActive(false);
    }
  }, []);

  const removeFile = (fileId: string) => {
    setFiles(prev => prev.filter(f => f.id !== fileId));
  };

  return (
    <div className="space-y-6">
      {/* Upload Zone */}
      <Card className="analytics-card">
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Upload className="h-5 w-5 text-primary" />
            <span>Загрузка файлов данных</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div
            className={`relative border-2 border-dashed rounded-lg p-8 text-center transition-colors ${
              dragActive 
                ? 'border-primary bg-primary/10' 
                : 'border-border hover:border-primary/50'
            }`}
            onDragEnter={handleDrag}
            onDragLeave={handleDrag}
            onDragOver={handleDrag}
            onDrop={handleDrop}
          >
            <input
              type="file"
              multiple
              accept=".xlsx,.xls,.csv"
              onChange={handleChange}
              className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
            />
            
            <div className="space-y-4">
              <div className="mx-auto w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center">
                <Upload className="h-8 w-8 text-primary" />
              </div>
              
              <div>
                <p className="text-lg font-medium">
                  Перетащите файлы сюда или нажмите для выбора
                </p>
                <p className="text-muted-foreground">
                  Поддерживаются: Excel (.xlsx, .xls) и CSV файлы
                </p>
              </div>
              
              <Button className="bg-primary hover:bg-primary-dark">
                Выбрать файлы
              </Button>
            </div>
          </div>

          {/* Recommended Upload Order */}
          <Alert className="mt-6">
            <Database className="h-4 w-4" />
            <AlertDescription>
              <strong>Рекомендуемый порядок загрузки:</strong>
              <br />
              1. Hardware Orders (HW.xlsx) - основной источник
              <br />
              2. Sales Reports (report.xlsx) - дополнительная информация
              <br />
              3. Остальные файлы в любом порядке
            </AlertDescription>
          </Alert>
        </CardContent>
      </Card>

      {/* File Processing List */}
      {files.length > 0 && (
        <Card className="analytics-card">
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <Clock className="h-5 w-5 text-primary" />
              <span>Обработка файлов</span>
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {files
                .sort((a, b) => fileTypeConfig[a.type].priority - fileTypeConfig[b.type].priority)
                .map((file) => {
                const config = fileTypeConfig[file.type];
                
                return (
                  <div key={file.id} className="border border-border rounded-lg p-4">
                    <div className="flex items-center justify-between mb-3">
                      <div className="flex items-center space-x-3">
                        <div className={`w-3 h-3 rounded-full ${config.color}`} />
                        <div>
                          <p className="font-medium">{file.name}</p>
                          <p className="text-sm text-muted-foreground">
                            {config.description} • {formatFileSize(file.size)}
                          </p>
                        </div>
                      </div>
                      
                      <div className="flex items-center space-x-2">
                        <Badge 
                          variant={
                            file.status === 'completed' ? 'default' :
                            file.status === 'error' ? 'destructive' :
                            file.status === 'processing' ? 'secondary' :
                            'outline'
                          }
                          className={
                            file.status === 'completed' ? 'bg-success text-success-foreground' :
                            file.status === 'processing' ? 'bg-primary text-primary-foreground' :
                            ''
                          }
                        >
                          {file.status === 'completed' && <CheckCircle className="w-3 h-3 mr-1" />}
                          {file.status === 'error' && <AlertTriangle className="w-3 h-3 mr-1" />}
                          {file.status === 'pending' && 'Ожидание'}
                          {file.status === 'processing' && 'Обработка'}
                          {file.status === 'completed' && 'Завершено'}
                          {file.status === 'error' && 'Ошибка'}
                        </Badge>
                        
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => removeFile(file.id)}
                        >
                          <X className="h-4 w-4" />
                        </Button>
                      </div>
                    </div>
                    
                    {(file.status === 'processing' || file.status === 'completed') && (
                      <div className="space-y-2">
                        <div className="flex justify-between text-sm">
                          <span>Прогресс обработки</span>
                          <span className="text-primary font-medium">{Math.round(file.progress)}%</span>
                        </div>
                        <Progress value={file.progress} className="h-2" />
                        
                        {file.status === 'completed' && (
                          <div className="grid grid-cols-3 gap-4 mt-3 text-sm">
                            <div className="text-center p-2 rounded bg-muted/50">
                              <p className="font-medium text-foreground">{file.recordsProcessed}</p>
                              <p className="text-muted-foreground">Обработано</p>
                            </div>
                            <div className="text-center p-2 rounded bg-success/10">
                              <p className="font-medium text-success">{file.recordsMatched}</p>
                              <p className="text-muted-foreground">Сопоставлено</p>
                            </div>
                            <div className="text-center p-2 rounded bg-warning/10">
                              <p className="font-medium text-warning">{file.duplicatesFound}</p>
                              <p className="text-muted-foreground">Дублей</p>
                            </div>
                          </div>
                        )}
                      </div>
                    )}
                    
                    {file.status === 'error' && file.errorMessage && (
                      <Alert className="mt-3" variant="destructive">
                        <AlertTriangle className="h-4 w-4" />
                        <AlertDescription>{file.errorMessage}</AlertDescription>
                      </Alert>
                    )}
                  </div>
                );
              })}
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
};