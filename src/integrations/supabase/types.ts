export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instanciate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "13.0.4"
  }
  public: {
    Tables: {
      files: {
        Row: {
          content_hash: string
          detected_delimiter: string | null
          detected_encoding: string | null
          duplicate_of_id: number | null
          error_message: string | null
          error_records: number | null
          file_size: number | null
          file_type: string
          file_url: string | null
          filename: string
          id: number
          matched_records: number | null
          original_name: string
          processed_records: number | null
          processed_sheet: string | null
          processing_finished_at: string | null
          processing_started_at: string | null
          processing_status: string | null
          records_count: number | null
          sheet_names: string[] | null
          similarity_percent: number | null
          uploaded_at: string | null
          uploaded_by: string | null
        }
        Insert: {
          content_hash: string
          detected_delimiter?: string | null
          detected_encoding?: string | null
          duplicate_of_id?: number | null
          error_message?: string | null
          error_records?: number | null
          file_size?: number | null
          file_type: string
          file_url?: string | null
          filename: string
          id?: number
          matched_records?: number | null
          original_name: string
          processed_records?: number | null
          processed_sheet?: string | null
          processing_finished_at?: string | null
          processing_started_at?: string | null
          processing_status?: string | null
          records_count?: number | null
          sheet_names?: string[] | null
          similarity_percent?: number | null
          uploaded_at?: string | null
          uploaded_by?: string | null
        }
        Update: {
          content_hash?: string
          detected_delimiter?: string | null
          detected_encoding?: string | null
          duplicate_of_id?: number | null
          error_message?: string | null
          error_records?: number | null
          file_size?: number | null
          file_type?: string
          file_url?: string | null
          filename?: string
          id?: number
          matched_records?: number | null
          original_name?: string
          processed_records?: number | null
          processed_sheet?: string | null
          processing_finished_at?: string | null
          processing_started_at?: string | null
          processing_status?: string | null
          records_count?: number | null
          sheet_names?: string[] | null
          similarity_percent?: number | null
          uploaded_at?: string | null
          uploaded_by?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "files_duplicate_of_id_fkey"
            columns: ["duplicate_of_id"]
            isOneToOne: false
            referencedRelation: "files"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "files_uploaded_by_fkey"
            columns: ["uploaded_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["user_id"]
          },
        ]
      }
      hardware_orders: {
        Row: {
          address: string | null
          brew_status: string | null
          brewing_time: string | null
          created_at: string | null
          creation_time: string | null
          delivery_time: string | null
          goods_name: string | null
          id: number
          machine_code: string | null
          order_number: string
          order_price: number | null
          order_resource: string | null
          order_type: string | null
          paying_time: string | null
          payment_status: string | null
          reason: string | null
          refund_time: string | null
          source_file_id: number | null
          taste_name: string | null
          updated_at: string | null
          version: number | null
        }
        Insert: {
          address?: string | null
          brew_status?: string | null
          brewing_time?: string | null
          created_at?: string | null
          creation_time?: string | null
          delivery_time?: string | null
          goods_name?: string | null
          id?: number
          machine_code?: string | null
          order_number: string
          order_price?: number | null
          order_resource?: string | null
          order_type?: string | null
          paying_time?: string | null
          payment_status?: string | null
          reason?: string | null
          refund_time?: string | null
          source_file_id?: number | null
          taste_name?: string | null
          updated_at?: string | null
          version?: number | null
        }
        Update: {
          address?: string | null
          brew_status?: string | null
          brewing_time?: string | null
          created_at?: string | null
          creation_time?: string | null
          delivery_time?: string | null
          goods_name?: string | null
          id?: number
          machine_code?: string | null
          order_number?: string
          order_price?: number | null
          order_resource?: string | null
          order_type?: string | null
          paying_time?: string | null
          payment_status?: string | null
          reason?: string | null
          refund_time?: string | null
          source_file_id?: number | null
          taste_name?: string | null
          updated_at?: string | null
          version?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "hardware_orders_source_file_id_fkey"
            columns: ["source_file_id"]
            isOneToOne: false
            referencedRelation: "files"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          created_at: string
          email: string
          full_name: string | null
          id: string
          role: string
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          email: string
          full_name?: string | null
          id?: string
          role?: string
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          email?: string
          full_name?: string | null
          id?: string
          role?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      unified_orders: {
        Row: {
          address: string | null
          brew_status: string | null
          brewing_time: string | null
          created_at: string | null
          creation_time: string | null
          delivery_time: string | null
          goods_name: string | null
          id: number
          is_temporary: boolean | null
          last_matched_at: string | null
          machine_code: string | null
          match_score: number | null
          order_number: string
          order_price: number | null
          order_resource: string | null
          order_type: string | null
          paying_time: string | null
          payment_status: string | null
          reason: string | null
          refund_time: string | null
          source_files: string[] | null
          taste_name: string | null
          updated_at: string | null
        }
        Insert: {
          address?: string | null
          brew_status?: string | null
          brewing_time?: string | null
          created_at?: string | null
          creation_time?: string | null
          delivery_time?: string | null
          goods_name?: string | null
          id?: number
          is_temporary?: boolean | null
          last_matched_at?: string | null
          machine_code?: string | null
          match_score?: number | null
          order_number: string
          order_price?: number | null
          order_resource?: string | null
          order_type?: string | null
          paying_time?: string | null
          payment_status?: string | null
          reason?: string | null
          refund_time?: string | null
          source_files?: string[] | null
          taste_name?: string | null
          updated_at?: string | null
        }
        Update: {
          address?: string | null
          brew_status?: string | null
          brewing_time?: string | null
          created_at?: string | null
          creation_time?: string | null
          delivery_time?: string | null
          goods_name?: string | null
          id?: number
          is_temporary?: boolean | null
          last_matched_at?: string | null
          machine_code?: string | null
          match_score?: number | null
          order_number?: string
          order_price?: number | null
          order_resource?: string | null
          order_type?: string | null
          paying_time?: string | null
          payment_status?: string | null
          reason?: string | null
          refund_time?: string | null
          source_files?: string[] | null
          taste_name?: string | null
          updated_at?: string | null
        }
        Relationships: []
      }
      user_roles: {
        Row: {
          id: string
          role: string
          user_id: string
        }
        Insert: {
          id?: string
          role: string
          user_id: string
        }
        Update: {
          id?: string
          role?: string
          user_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      has_role: {
        Args: { _user_id: string; _role: string }
        Returns: boolean
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
