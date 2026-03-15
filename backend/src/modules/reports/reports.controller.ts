import { Controller, Post, Body } from '@nestjs/common';
import { ReportsService } from './reports.service';
import { Public } from '@/auth/decorators/public.decorator';

@Controller('reports')
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Public()
  @Post('send')
  async sendReport(@Body() reportData: any) {
    return this.reportsService.sendUsageReport(reportData);
  }
}
