import { Controller, Get, Post, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { BlockingService } from './blocking.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

@Controller('blocking')
export class BlockingController {
  constructor(private blockingService: BlockingService) {}

  @Get('domains')
  async getDomains() {
    const domains = await this.blockingService.getDomains();
    return { domains };
  }

  @UseGuards(JwtAuthGuard)
  @Post('domains')
  async addDomain(@Body() body: { domain: string; category: string }) {
    return this.blockingService.addDomain(body.domain, body.category);
  }

  @UseGuards(JwtAuthGuard)
  @Delete('domains/:id')
  async removeDomain(@Param('id') id: string) {
    return this.blockingService.removeDomain(id);
  }

  @Get('apps')
  async getApps() {
    return this.blockingService.getApps();
  }

  @UseGuards(JwtAuthGuard)
  @Post('apps')
  async addApp(@Body() body: { packageName: string; appName: string; category: string }) {
    return this.blockingService.addApp(body.packageName, body.appName, body.category);
  }
}
