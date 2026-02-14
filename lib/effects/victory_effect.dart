import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class VictoryEffect extends PositionComponent {
  final Random _rnd = Random();

  VictoryEffect() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // We will spawn multiple explosions
    add(
      TimerComponent(
        period: 0.5,
        repeat: true,
        onTick: _spawnExplosion,
      ),
    );
  }

  void _spawnExplosion() {
    Vector2 explosionPos = Vector2(
      (_rnd.nextDouble() - 0.5) * 400, // Random X offset
      (_rnd.nextDouble() - 0.5) * 400, // Random Y offset
    );

    parent?.add(
      ParticleSystemComponent(
        position: position + explosionPos,
        particle: Particle.generate(
          count: 30,
          lifespan: 1.5,
          generator: (i) {
            double angle = _rnd.nextDouble() * 2 * pi;
            double speed = _rnd.nextDouble() * 200 + 50;
            return AcceleratedParticle(
              acceleration: Vector2(0, 200), // Gravity
              speed: Vector2(cos(angle), sin(angle)) * speed,
              child: ComputedParticle(
                renderer: (canvas, particle) {
                  Paint paint = Paint()
                    ..color = Colors.amber.withValues(alpha: 1 - particle.progress);
                  canvas.drawCircle(Offset.zero, 3.0 * (1 - particle.progress), paint);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
